create
or replace view STOCK_ANALYTICS.PUBLIC.MONTHLY_OHLC_6Y(
    SYMBOL,
    DATE,
    OPEN,
    HIGH,
    LOW,
    CLOSE,
    ADJCLOSE,
    VOLUME,
    UNADJUSTEDVOLUME,
    CHANGE,
    CHANGEPERCENT,
    VWAP,
    LABEL,
    CHANGEOVERTIME,
    SNAPSHOT_DATE,
    MONTHLY_RETURN_PERC
) as (
    -- Define a CTE to calculate the monthly closing price
    WITH MonthlyClosing AS (
        SELECT
            distinct symbol,
            DATE_TRUNC('MONTH', date) AS month,
            LAST_VALUE(close) IGNORE NULLS OVER (
                PARTITION BY symbol,
                DATE_TRUNC('MONTH', date)
                ORDER BY
                    date ROWS BETWEEN UNBOUNDED PRECEDING
                    AND UNBOUNDED FOLLOWING
            ) AS month_end_close
        FROM
            ohlc_6y
        order by
            month desc
    ),
    MonthlyReturns AS (
        SELECT
            symbol,
            month,
            monthly_return_perc
        FROM
            (
                SELECT
                    symbol,
                    month,
                    LAG(month_end_close) OVER (
                        PARTITION BY symbol
                        ORDER BY
                            month
                    ) AS prev_month_end_close,
                    month_end_close,
                    round(
                        (
                            (month_end_close - prev_month_end_close) / prev_month_end_close
                        ) * 100,
                        2
                    ) as monthly_return_perc,
                FROM
                    MonthlyClosing
                order by
                    month desc
            )
    ),
    ohlc_6y_with_returns as (
        SELECT
            o.*,
            m.monthly_return_perc
        FROM
            ohlc_6y o
            LEFT JOIN MonthlyReturns m ON o.symbol = m.symbol
            AND DATE_TRUNC('MONTH', o.date) = m.month
    ),
    RankedMonthlyData AS (
        SELECT
            *
        FROM
            ohlc_6y_with_returns qualify ROW_NUMBER() OVER (
                PARTITION BY symbol,
                DATE_TRUNC('MONTH', date)
                ORDER BY
                    date DESC
            ) = 1
        order by
            symbol,
            date desc
    )
    select
        *
    from
        rankedmonthlydata
);;