#!/usr/bin/env golosh

----

----
module gaas

import io.vertx.core.Vertx
import io.vertx.core.http.HttpServer
import io.vertx.ext.web.Router
import io.vertx.ext.web.handler

#import gololang.JSON
import gololang.Errors

let vertx = Vertx.vertx()

let env = gololang.EvaluationEnvironment()

function main = |args| {

  let server = vertx: createHttpServer()
  let router = Router.router(vertx)
  router: route(): handler(BodyHandler.create())

  let port =  Integer.parseInt(System.getenv(): get("PORT") orIfNull "8080")



  router: post("/exec"): handler(|context| {
    context: response(): putHeader("content-type", "application/json;charset=UTF-8")

    trying({
      let data = JSON.parse(context: getBodyAsString())
      let code = data: get("code")
      let mod = env: anonymousModule(code)
      return fun("res", mod)
    })
    : either(
      |resFunction| {
        trying({
          return resFunction()
        })
        : either(
          |res| {
            context: response(): end(JSON.stringify(DynamicObject(): result(res)), "UTF-8")
          },
          |error| {
            println(error)
            context: response(): end(JSON.stringify(DynamicObject(): result(error: message())), "UTF-8")
          }
        )
      },
      |error| {
        println(error)
        context: response(): end(JSON.stringify(DynamicObject(): result(error: message())), "UTF-8")
      }
    )



  })

  router: get("/about"): handler(|context| {
    context: response(): putHeader("content-type", "application/json;charset=UTF-8")
    context: response(): end(JSON.stringify(DynamicObject(): about("Golo As A Service 😛")), "UTF-8")
  })

  router: route("/*"): handler(StaticHandler.create())

  server: requestHandler(|httpRequest| -> router: accept(httpRequest)): listen(port)

  println("🌍  Gaas server listening on " + port)

}
