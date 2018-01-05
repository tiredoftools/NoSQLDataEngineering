package es.um.nosql.schemainference.m2t.mongoose

import java.io.File
import es.um.nosql.schemainference.util.emf.ModelLoader
import es.um.nosql.schemainference.entitydifferentiation.EntitydifferentiationPackage
import es.um.nosql.schemainference.entitydifferentiation.EntityDifferentiation
import java.io.PrintStream

class DiffMongooseBaseGen
{
  var modelName = "";
  static File outputDir;

  // For the base generation we need three items:
  // - The folder to output the generation
  // - The model name to name the files and variables
  // - The root entities (entities with at least one root version), so we can include some variables and generate base validators.
  def m2t(File modelFile, File outputFolder)
  {
    val loader = new ModelLoader(EntitydifferentiationPackage.eINSTANCE);
    val diff = loader.load(modelFile, EntityDifferentiation);

    m2t(diff, outputFolder);
  }

  /**
   * Method used to start the generation process from an EntityDifferentiation object
   */
  def void m2t(EntityDifferentiation diff, File outputFolder)
  {
    outputDir = outputFolder;
    modelName = diff.name;

    outputDir.toPath.resolve("app").resolve("models").resolve("util").toFile.mkdirs;
    writeToFile("package.json", generatePackageFile());
    writeToFile("app/models/util/UnionType.js", generateUnionTypeFile());
    writeToFile("checkDbConsistency.js", generateCheckDbFile(diff));
    writeToFile("addDbObjects.js", generateAddDbFile(diff));
  }

  def generatePackageFile()
  '''
  {
    "name": "node-api",
    "main": "server.js",
    "dependencies": {
      "body-parser": "^1.16.1",
      "express": "^4.14.1",
      "mongoose": "*"
    }
  }
  '''

  def generateUnionTypeFile()
  '''
  'use strict'
  
  var mongoose = require('mongoose');
  
  function makeUnionType(name, ...types)
  {
    function isArray(type) { return type.match(new RegExp("^\\[")) && type.match(new RegExp("\\]$"));}

    var capitalizedName = name.charAt(0).toUpperCase() + name.slice(1);
    var typeFunction = function(key, options) {mongoose.SchemaType.call(this, key, options, capitalizedName);}
    typeFunction.prototype = Object.create(mongoose.SchemaType.prototype);
    typeFunction.prototype.cast = function(val)
    {
      var funcCheckMongooseType = function(type)
      {
        return function (value)
        {
          // If the type is kind of [mongooseType]...
          if (isArray(type))
          {
            // Remember to remove the [type] brackets...we should cast each value in the array to the given type (no heterogeneous types)
            var arrResult = [];

            if (value.constructor !== Array)
              arrResult.push(mongoose.Schema.Types[type.slice(1, -1)].prototype.cast(value));
            else
              for (var i of value)
                arrResult.push(mongoose.Schema.Types[type.slice(1, -1)].prototype.cast(i));

            return arrResult;
          }
          else
            // Else the type was just mongooseType
            return mongoose.Schema.Types[type].prototype.cast(value);
        }
      };

      var funcCheckMongooseSchema = function (type)
      {
        return function (value)
        {
          if (isArray(type))
          {
            // Remember to remove the [type] brackets...we should check each object constructor...
            if (value.constructor !== Array)
            {
              if (value.constructor.modelName === type.slice(1, -1))
                return [value];
              else
              {
                var returnValue = mongoose.models[type.slice(1, -1)].hydrate(value);
                if (returnValue.validateSync() !== undefined)
                  throw new Error();
                else
                  return [returnValue];
              }
            }
            else
            {
              var returnValue = [];
              for (var singleElement of value)
              {
                if (singleElement.constructor.modelName !== type.slice(1, -1))
                  returnValue.push(singleElement);
                else
                {
                  var elemValue = mongoose.models[type.slice(1, -1)].hydrate(singleElement);
                  if (elemValue.validateSync() !== undefined)
                    throw new Error();
                  else
                    returnValue.push(elemValue);
                }
              }
              return returnValue;
            }
          }
          else
          {
            // When a model object is created...
            if (value.constructor.modelName === type)
              return value;
            else
            {
              // When a model object is loaded...cast and validate
              var returnValue = mongoose.models[type].hydrate(value);
              if (returnValue.validateSync() !== undefined)
                throw new Error();
              else
                return returnValue;
            }
          }
        }
      };

      var castFunctions = [];
      var returnVal = val;

      // For each Union type we try to cast the value to that type.
      // If for some type the cast is successful, we can return the casted value
      // If the casting fails for each type, then the value was not compatible with the Union type.
      for (var i = 0; i < types.length; i++)
      {
        castFunctions[i] = (types[i] in mongoose.Schema.Types || (isArray(types[i]) && types[i].slice(1, -1) in mongoose.Schema.Types))?
          funcCheckMongooseType(types[i]) : funcCheckMongooseSchema(types[i]);

        try
        {
          returnVal = castFunctions[i](val);
        } catch (typeError)
        {
          if (i == types.length - 1)
            throw new Error(capitalizedName + ': ' + val + ' couldn\'t be cast to any type of ' + types);
          else
            continue;
        }

        break;
      }

      return returnVal;
    }

    Object.defineProperty(typeFunction, "name", { value: capitalizedName });
    mongoose.Schema.Types[capitalizedName] = typeFunction;
  
    return typeFunction;
  }

  module.exports = makeUnionType;
  '''

  def generateCheckDbFile(EntityDifferentiation diff)
  '''
  var mongoose = require('mongoose');
  mongoose.Promise = require('bluebird');
  mongoose.connect('mongodb://127.0.0.1/«modelName»',
  {
    useMongoClient: true
  }, function(err)
  {
    if (err)
      console.log(err);
    else
      console.log('Connected to 127.0.0.1/«modelName»');
  });
  mongoose.set('debug', true);
  var db = mongoose.connection;
  db.on('error', console.error.bind(console, 'connection error: '));

  «FOR e : diff.entityDiffSpecs.map[ed | ed.entity]»
    var «e.name» = require('./app/models/«e.name»Schema');
  «ENDFOR»

  db.once('open', function()
  {
    «FOR e : diff.entityDiffSpecs.filter[ed | ed.entity.entityversions.exists[ev | ev.isRoot]].map[ed | ed.entity]»
      «e.name».find(function(err, result)
      {
        if (err)
          return console.error(err);

        console.log("Checking consistency of the \"«e.name»\" table");
        var errorNumber = 0;

        result.forEach(function(«e.name.toLowerCase»)
        {
          var validation = «e.name.toLowerCase».validateSync();
          if (typeof validation !== "undefined")
          {
            console.log(validation);
            errorNumber++;
          }
        });

        if (errorNumber)
          console.log("\"«e.name»\" table: " + errorNumber + " errors found");
        else
          console.log("\"«e.name»\" table: No errors found!");
      });

    «ENDFOR»
  });
  '''

  def generateAddDbFile(EntityDifferentiation diff)
  '''
  var mongoose = require('mongoose');
  mongoose.Promise = require('bluebird');
  mongoose.connect('mongodb://127.0.0.1/«modelName»',
  {
    useMongoClient: true
  }, function(err)
  {
    if (err)
      console.log(err);
    else
      console.log('Connected to 127.0.0.1/«modelName»');
  });
  mongoose.set('debug', true);
  var db = mongoose.connection;
  db.on('error', console.error.bind(console, 'connection error: '));

  «FOR e : diff.entityDiffSpecs.map[ed | ed.entity]»
    var «e.name» = require('./app/models/«e.name»Schema');
  «ENDFOR»

  var err;
  «FOR e : diff.entityDiffSpecs.map[ed | ed.entity] SEPARATOR '\n'»
    var «e.name.toLowerCase» = new «e.name»({});
    err = «e.name.toLowerCase».validateSync();
    if (err !== undefined)
      console.log(err);
  «ENDFOR»
  '''

  /**
   * Method used to write a generated CharSequence to a file
   */
  private def writeToFile(String filename, CharSequence toWrite)
  {
    val outFile = outputDir.toPath().resolve(filename).toFile()
    val outFileWriter = new PrintStream(outFile)
    outFileWriter.print(toWrite)
    outFileWriter.close()
  }
}