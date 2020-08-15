package com.wla.transformer.hive;


import java.io.IOException;

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;

import com.wla.transformer.model.dim.base.PlatformDimension;
import com.wla.transformer.service.IDimensionConverter;
import com.wla.transformer.service.impl.DimensionConverterImpl;

/**
 * 操作日期dimension 相关的udf
 * 
 * @author Liu Wencong
 *
 */
public class PlatformDimensionUDF extends UDF {
    private IDimensionConverter converter = new DimensionConverterImpl();

   

    /**
     * 根据给定的日期（格式为:yyyy-MM-dd）至返回id
     * 
     * @param day
     * @return
     */
    public IntWritable evaluate(Text platform) {
    	PlatformDimension platformDimension = new PlatformDimension(platform.toString());
        try {
            int id = this.converter.getDimensionIdByValue(platformDimension);
            return new IntWritable(id);
        } catch (IOException e) {
            throw new RuntimeException("获取id异常");
        }
    }
}
