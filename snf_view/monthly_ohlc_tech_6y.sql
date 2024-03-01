create
or replace view STOCK_ANALYTICS.PUBLIC.MONTHLY_OHLC_TECH_IND_6Y(
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
    CHANGEOVERTIME,
    SMA_5D,
    SMA_10D,
    SMA_15D,
    SMA_20D,
    EMA_5D,
    EMA_10D,
    EMA_15D,
    EMA_20D,
    WMA_5D,
    WMA_10D,
    WMA_15D,
    WMA_20D,
    DEMA_5D,
    DEMA_10D,
    DEMA_15D,
    DEMA_20D,
    TEMA_5D,
    TEMA_10D,
    TEMA_15D,
    TEMA_20D,
    WILLIAMS_5D,
    WILLIAMS_10D,
    WILLIAMS_15D,
    WILLIAMS_20D,
    RSI_5D,
    RSI_10D,
    RSI_15D,
    RSI_20D,
    ADX_5D,
    ADX_10D,
    ADX_15D,
    ADX_20D,
    STANDARDDEVIATION_5D,
    STANDARDDEVIATION_10D,
    STANDARDDEVIATION_15D,
    STANDARDDEVIATION_20D,
    MONTHLY_RETURN_PERC,
    TARGET
) as (
    WITH MONTHLY_TECHNICAL_INDICATORS AS (
        SELECT
            *
        FROM
            TECHNICAL_INDICATORS qualify ROW_NUMBER() OVER (
                PARTITION BY symbol,
                DATE_TRUNC('MONTH', date)
                ORDER BY
                    date DESC
            ) = 1
        order by
            symbol,
            date desc
    )
    SELECT
        O.* EXCLUDE (SNAPSHOT_DATE, MONTHLY_RETURN_PERC, LABEL),
        M.* EXCLUDE(DATE, SYMBOL),
        O.MONTHLY_RETURN_PERC,
        LAG(O.MONTHLY_RETURN_PERC, 1) OVER (
            PARTITION BY O.symbol
            ORDER BY
                O.DATE DESC
        ) AS TARGET
    FROM
        MONTHLY_OHLC_6Y O
        LEFT JOIN MONTHLY_TECHNICAL_INDICATORS M ON o.symbol = m.symbol
        AND O.DATE = M.DATE
);