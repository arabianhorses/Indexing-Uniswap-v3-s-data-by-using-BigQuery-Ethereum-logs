      CREATE TABLE `lpscanner_xyz.ethereum_uniswapv3_swaps` AS (
        SELECT                                                                                                  
          'ethereum' AS chain,
          'uniswap_v3' AS protocol,
          t.address AS pool_address,
          CONCAT('0x', SUBSTR(t.topics[SAFE_OFFSET(1)], 27, 40)) AS sender,
          CONCAT('0x', SUBSTR(t.topics[SAFE_OFFSET(2)], 27, 40)) AS recipient,                                  
          lpscanner.hex_to_int_str(SUBSTR(t.data, 3, 64)) AS amount0, --hex_to_int_str and hex_to_uints are UDFs we shared them in same repo
          lpscanner.hex_to_int_str(SUBSTR(t.data, 67, 64)) AS amount1,                                          
          lpscanner.hex_to_uint(SUBSTR(t.data, 131, 64)) AS sqrtPriceX96,
          lpscanner.hex_to_int_str(SUBSTR(t.data, 195, 64)) AS liquidity,                                       
          lpscanner.hex_to_int_str(SUBSTR(t.data, 259, 64)) AS tick,
          t.transaction_hash,                                                                                   
          t.block_timestamp,
          t.block_number,                                                                                       
          t.log_index,
          t.generatedindex AS generatedIndex
        FROM `lpscanner.ethereum_target_data` t --same raw logs that coming from this public table bigquery-public-data.goog_blockchain_ethereum_mainnet_us.logs`; just pre selected rows for efficienct and added generatedIndex column = block_number * 1000000 + log_index
        INNER JOIN `lpscanner.ethereum_known_pool_addresses` kp  ON kp.pool_address = t.address --you may check creator query of this table and sample rows from this table in same repo
        WHERE kp.protocol = 'uniswap_v3'                                                                        
          AND t.topics[SAFE_OFFSET(0)] = '0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67'   
        QUALIFY ROW_NUMBER() OVER (PARTITION BY t.generatedindex ORDER BY t.block_timestamp) = 1 
                                                                  );
