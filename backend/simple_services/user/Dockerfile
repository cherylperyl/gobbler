FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Copy csproj separately to only restore dependencies when csproj changes
COPY *.csproj ./
RUN dotnet restore

# Copy everything
COPY . ./

# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final-env
WORKDIR /app

# copy from previous environment
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "user.dll"]