module Program

open System
open System.Collections.Generic
open System.IO
open System.Linq
open System.Threading.Tasks
open Microsoft.AspNetCore
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.AspNetCore.Http
open Microsoft.Extensions.DependencyInjection
open Microsoft.AspNetCore.Hosting
open Microsoft.Extensions.Configuration
open Microsoft.Extensions.Logging
open Giraffe
open FSharp.Control.Tasks.V2

type Price = { ItemId: string; Price: Decimal }

let getPriceForItem itemId : HttpHandler =
    match itemId with
    | "1" -> { ItemId = "1"; Price = 2.00M } |> Successful.OK
    | "2" -> { ItemId = "2"; Price = 4.50M } |> Successful.OK
    | _ -> RequestErrors.NOT_FOUND ()

let webApp =
    choose [
        routef "/item/%s/price" getPriceForItem
        route "/health" >=> Successful.OK "Everything's fine here, how are you?" ]

let configureApp (app : IApplicationBuilder) =
    app.UseGiraffe webApp

let configureServices (services : IServiceCollection) =
    services.AddGiraffe() |> ignore

let configureLogging (builder : ILoggingBuilder) =
    builder.AddConsole() |> ignore

[<EntryPoint>]
let main _ =
    WebHostBuilder()
        .UseKestrel()
        .Configure(Action<IApplicationBuilder> configureApp)
        .ConfigureServices(configureServices)
        .ConfigureLogging(configureLogging)
        .Build()
        .Run()
    0
