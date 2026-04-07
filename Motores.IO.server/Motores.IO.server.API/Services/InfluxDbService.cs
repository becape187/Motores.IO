using InfluxDB.Client;
using InfluxDB.Client.Api.Domain;
using InfluxDB.Client.Writes;
using Motores.IO.server.API.DTOs;
using Motores.IO.server.API.Models;

namespace Motores.IO.server.API.Services;

public class InfluxDbService : IDisposable
{
    private readonly InfluxDBClient _client;
    private readonly string _bucket;
    private readonly string _org;
    private readonly ILogger<InfluxDbService> _logger;
    private const string Measurement = "historico_motor";

    public InfluxDbService(IConfiguration configuration, ILogger<InfluxDbService> logger)
    {
        _logger = logger;

        var url = configuration["InfluxDb:Url"] ?? "http://localhost:8086";
        var token = configuration["InfluxDb:Token"] ?? "";
        _org = configuration["InfluxDb:Org"] ?? "automais";
        _bucket = configuration["InfluxDb:Bucket"] ?? "motores_historico";

        _client = new InfluxDBClient(url, token);
        _logger.LogInformation("InfluxDbService inicializado: {Url}, bucket={Bucket}, org={Org}", url, _bucket, _org);
    }

    public async Task WriteHistoricoAsync(HistoricoMotor historico)
    {
        var point = PointData.Measurement(Measurement)
            .Tag("motorId", historico.MotorId.ToString())
            .Tag("status", historico.Status ?? "")
            .Field("corrente", (double)historico.Corrente)
            .Field("tensao", (double)historico.Tensao)
            .Field("temperatura", (double)historico.Temperatura)
            .Timestamp(historico.Timestamp.ToUniversalTime(), WritePrecision.Ms);

        if (historico.CorrenteMedia.HasValue)
            point = point.Field("correnteMedia", (double)historico.CorrenteMedia.Value);
        if (historico.CorrenteMaxima.HasValue)
            point = point.Field("correnteMaxima", (double)historico.CorrenteMaxima.Value);
        if (historico.CorrenteMinima.HasValue)
            point = point.Field("correnteMinima", (double)historico.CorrenteMinima.Value);

        var writeApi = _client.GetWriteApiAsync();
        await writeApi.WritePointAsync(point, _bucket, _org);
    }

    public async Task WriteBatchAsync(IEnumerable<HistoricoMotor> historicos)
    {
        var points = historicos.Select(h =>
        {
            var point = PointData.Measurement(Measurement)
                .Tag("motorId", h.MotorId.ToString())
                .Tag("status", h.Status ?? "")
                .Field("corrente", (double)h.Corrente)
                .Field("tensao", (double)h.Tensao)
                .Field("temperatura", (double)h.Temperatura)
                .Timestamp(h.Timestamp.ToUniversalTime(), WritePrecision.Ms);

            if (h.CorrenteMedia.HasValue)
                point = point.Field("correnteMedia", (double)h.CorrenteMedia.Value);
            if (h.CorrenteMaxima.HasValue)
                point = point.Field("correnteMaxima", (double)h.CorrenteMaxima.Value);
            if (h.CorrenteMinima.HasValue)
                point = point.Field("correnteMinima", (double)h.CorrenteMinima.Value);

            return point;
        }).ToList();

        var writeApi = _client.GetWriteApiAsync();
        await writeApi.WritePointsAsync(points, _bucket, _org);
    }

    /// <summary>
    /// Resumo leve para diagnóstico sem UI: último ponto e contagem por intervalo (campo corrente = 1 ponto por medição).
    /// </summary>
    public async Task<InfluxIngestaoResumoDto> ObterResumoIngestaoAsync(bool contarTodoPeriodo = false)
    {
        var dto = new InfluxIngestaoResumoDto { Bucket = _bucket, Org = _org };
        try
        {
            dto.UltimoPontoUtc = await FluxUltimoTimestampCorrenteAsync();
            dto.PontosUltimos30Dias = await FluxCountCorrenteAsync("-30d");
            if (contarTodoPeriodo)
            {
                dto.Aviso = "Contagem total pode ser lenta e pesar CPU/memória em buckets grandes.";
                dto.PontosTodoPeriodo = await FluxCountCorrenteAsync("1970-01-01T00:00:00Z");
            }

            dto.InfluxRespondendo = true;
        }
        catch (Exception ex)
        {
            dto.InfluxRespondendo = false;
            dto.ErroConexao = ex.Message;
            _logger.LogWarning(ex, "Falha ao consultar resumo do InfluxDB");
        }

        return dto;
    }

    private async Task<DateTime?> FluxUltimoTimestampCorrenteAsync()
    {
        var flux = $"""
            from(bucket: "{_bucket}")
                |> range(start: -87600h)
                |> filter(fn: (r) => r["_measurement"] == "{Measurement}" and r["_field"] == "corrente")
                |> last()
            """;

        var tables = await _client.GetQueryApi().QueryAsync(flux, _org);
        foreach (var table in tables)
        {
            foreach (var record in table.Records)
                return record.GetTime()?.ToDateTimeUtc();
        }

        return null;
    }

    private async Task<long?> FluxCountCorrenteAsync(string rangeStart)
    {
        var flux = $"""
            from(bucket: "{_bucket}")
                |> range(start: {rangeStart})
                |> filter(fn: (r) => r["_measurement"] == "{Measurement}" and r["_field"] == "corrente")
                |> group()
                |> count()
            """;

        var tables = await _client.GetQueryApi().QueryAsync(flux, _org);
        foreach (var table in tables)
        {
            foreach (var record in table.Records)
            {
                var v = record.GetValue();
                if (v is long l)
                    return l;
                if (v is int i)
                    return i;
                if (v is double d)
                    return (long)d;
                if (v is ulong ul)
                    return (long)ul;
            }
        }

        return 0;
    }

    public async Task<List<(DateTime Time, double Corrente)>> QueryPontosCorrenteAsync(Guid motorId, DateTime? desde = null)
    {
        var rangeStart = desde.HasValue
            ? desde.Value.ToUniversalTime().ToString("o")
            : "1970-01-01T00:00:00Z";

        var flux = $"""
            from(bucket: "{_bucket}")
                |> range(start: {rangeStart})
                |> filter(fn: (r) => r["_measurement"] == "{Measurement}" and r["_field"] == "corrente" and r["motorId"] == "{motorId}")
                |> sort(columns: ["_time"])
            """;

        var tables = await _client.GetQueryApi().QueryAsync(flux, _org);

        var result = new List<(DateTime Time, double Corrente)>();
        foreach (var table in tables)
        {
            foreach (var record in table.Records)
            {
                var time = record.GetTime()?.ToDateTimeUtc() ?? DateTime.UtcNow;
                var value = record.GetValue();
                double corrente = 0;
                if (value is double d)
                    corrente = d;
                else if (value is long l)
                    corrente = l;
                else if (value != null)
                    corrente = Convert.ToDouble(value);

                result.Add((time, corrente));
            }
        }

        return result;
    }

    public async Task<List<HistoricoMotor>> QueryHistoricoAsync(
        Guid? motorId = null,
        DateTime? dataInicio = null,
        DateTime? dataFim = null)
    {
        var rangeStart = dataInicio.HasValue
            ? dataInicio.Value.ToUniversalTime().ToString("o")
            : "-30d";

        var rangeStop = dataFim.HasValue
            ? $", stop: {dataFim.Value.ToUniversalTime():o}"
            : "";

        var filterMotor = motorId.HasValue
            ? $"|> filter(fn: (r) => r[\"motorId\"] == \"{motorId.Value}\")"
            : "";

        var flux = $"""
            from(bucket: "{_bucket}")
                |> range(start: {rangeStart}{rangeStop})
                |> filter(fn: (r) => r["_measurement"] == "{Measurement}")
                {filterMotor}
                |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
                |> sort(columns: ["_time"], desc: true)
            """;

        var tables = await _client.GetQueryApi().QueryAsync(flux, _org);

        var result = new List<HistoricoMotor>();
        foreach (var table in tables)
        {
            foreach (var record in table.Records)
            {
                var h = new HistoricoMotor
                {
                    Id = Guid.NewGuid(),
                    MotorId = Guid.Parse(record.Values["motorId"]?.ToString() ?? ""),
                    Timestamp = record.GetTime()?.ToDateTimeUtc() ?? DateTime.UtcNow,
                    Status = record.Values.TryGetValue("status", out var s) ? s?.ToString() ?? "" : "",
                    Corrente = GetDecimalField(record, "corrente"),
                    Tensao = GetDecimalField(record, "tensao"),
                    Temperatura = GetDecimalField(record, "temperatura"),
                    CorrenteMedia = GetNullableDecimalField(record, "correnteMedia"),
                    CorrenteMaxima = GetNullableDecimalField(record, "correnteMaxima"),
                    CorrenteMinima = GetNullableDecimalField(record, "correnteMinima"),
                };
                result.Add(h);
            }
        }

        return result;
    }

    public async Task DeleteByMotorIdAsync(Guid motorId)
    {
        var deleteApi = _client.GetDeleteApi();
        var predicate = $"motorId=\"{motorId}\"";
        await deleteApi.Delete(
            DateTime.UnixEpoch,
            DateTime.UtcNow.AddYears(1),
            predicate,
            _bucket,
            _org);

        _logger.LogInformation("Dados do InfluxDB deletados para motorId={MotorId}", motorId);
    }

    public async Task DeleteByTimestampAsync(Guid motorId, DateTime timestamp)
    {
        var deleteApi = _client.GetDeleteApi();
        var start = timestamp.AddMilliseconds(-1);
        var stop = timestamp.AddMilliseconds(1);
        var predicate = $"motorId=\"{motorId}\"";
        await deleteApi.Delete(start, stop, predicate, _bucket, _org);
    }

    private static decimal GetDecimalField(InfluxDB.Client.Core.Flux.Domain.FluxRecord record, string field)
    {
        if (record.Values.TryGetValue(field, out var value) && value != null)
            return Convert.ToDecimal(value);
        return 0m;
    }

    private static decimal? GetNullableDecimalField(InfluxDB.Client.Core.Flux.Domain.FluxRecord record, string field)
    {
        if (record.Values.TryGetValue(field, out var value) && value != null)
            return Convert.ToDecimal(value);
        return null;
    }

    public void Dispose()
    {
        _client.Dispose();
    }
}
