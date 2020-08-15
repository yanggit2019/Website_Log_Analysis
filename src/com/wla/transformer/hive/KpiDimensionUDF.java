package com.wla.transformer.hive;


import java.io.IOException;

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;

import com.wla.transformer.model.dim.base.KpiDimension;
import com.wla.transformer.service.IDimensionConverter;
import com.wla.transformer.service.impl.DimensionConverterImpl;

/**
 * 操作日期dimension 相关的udf
 * 
 * @author Liu Wencong
 *
 */
public class KpiDimensionUDF extends UDF {
    private IDimensionConverter converter = new DimensionConverterImpl();

   

    /**
     * 根据给定的日期（格式为:yyyy-MM-dd）至返回id
     * 
     * @param day
     * @return
     */
    public IntWritable evaluate(Text kpi) {
    	KpiDimension kpiDimension = new KpiDimension(kpi.toString());
        try {
            int id = this.converter.getDimensionIdByValue(kpiDimension);
            return new IntWritable(id);
        } catch (IOException e) {
            throw new RuntimeException("获取id异常");
        }
    }
}
