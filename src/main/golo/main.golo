#!/usr/bin/env golosh

----
----
module gaas

import gololang.Errors
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

let env = gololang.EvaluationEnvironment()

function main = |args| {
  let port =  Integer.parseInt(System.getenv(): get("PORT") orIfNull "8080")
  setPort(port)
  #externalStaticFileLocation("/public")
  staticFileLocation("/public")

  get("/about", |request, response| -> trying({
    return "Golo As A Service"
  })
  : either(
    |message| -> response: json(DynamicObject(): about(message)),
    |error| -> response: json(DynamicObject(): error(error))
  ))


  post("/exec", |request, response| -> trying({
    let data = JSON.parse(request: body())
    let code = data: get("code")
    let mod = env: anonymousModule(code)
    let res = fun("res", mod)
    return res()
  })
  : either(
    |message| -> response: json(DynamicObject(): result(message)),
    |error| {
      println(error)
      return response: json(DynamicObject(): result(error: message()))
    }
  ))

  println("🌍  Gaas server listening on " + port)

}
