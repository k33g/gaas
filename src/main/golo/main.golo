#!/usr/bin/env golosh

----
----
module gaas

import gololang.Errors
module gololang.JSON
import spark.Spark


augment spark.Response {
  function json = |this, content| {
    this: type("application/json;charset=UTF-8")
    return JSON.stringify(content)
  }
  function text = |this, content| {
    this: type("text/plain;charset=UTF-8")
    return content
  }
}

augment spark.Request {
  function bodyToDynamicObject = |this| -> JSON.toDynamicObjectFromJSONString(this: body())
}

let env = gololang.EvaluationEnvironment()

function main = |args| {
  let port =  Integer.parseInt(System.getenv(): get("PORT") orIfNull "8080")
  setPort(port)
  #externalStaticFileLocation("/public")
  staticFileLocation("/public")

  get("/about", |request, response| -> trying({
    return DynamicObject(): about("Golo As A Service")
  })
  : either(
    |message| -> response: json(message),
    |error| -> response: json(DynamicObject(): error(error))
  ))


  post("/exec", |request, response| -> trying({
    let data = request: bodyToDynamicObject()
    let code = data: code()
    let mod = env: anonymousModule(code)
    let res = fun("res", mod)
    return DynamicObject(): res(res())
  })
  : either(
    |message| -> response: json(message),
    |error| {
      println(error)
      return response: json(DynamicObject(): error(error))
    }
  ))

  println("🌍  Gaas server listening on " + port)

}
