package es.um.nosql.schemainference.db.interfaces;

import java.io.File;
import java.io.IOException;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import es.um.nosql.schemainference.db.adapters.DbClient;

public class EPol2Db
{
	private DbClient client;

	public EPol2Db(DbClient client)
	{
		this.client = client;
	}

	public void storeJSONContent(String jsonRoute, String dbName)
	{
		try
		{
			JsonNode rootObj = new ObjectMapper().readTree(new File(jsonRoute));
			rootObj.fieldNames().forEachRemaining( fieldName ->
			{
				if (!fieldName.equals("meta"))
				{
					JsonNode collection = rootObj.get(fieldName);
					if (collection.size() > 0)
						client.insert(dbName, fieldName, collection.toString());
				}
			});
		} catch (JsonProcessingException e)
		{
			e.printStackTrace();
		} catch (IOException e)
		{
			e.printStackTrace();
		}
	}
}