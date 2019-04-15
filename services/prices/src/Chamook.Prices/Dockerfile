FROM microsoft/dotnet:2.2-aspnetcore-runtime
ARG source=.
WORKDIR /app
EXPOSE 80
COPY "bin/Release/netcoreapp2.2/publish/" .
ENTRYPOINT ["dotnet", "Chamook.Prices.dll"]