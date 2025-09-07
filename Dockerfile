# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Install Node.js
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY src/WebhookApp/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY src/WebhookApp/ ./
WORKDIR /app/ClientApp
RUN npm install
RUN npm run build

WORKDIR /app
RUN dotnet publish -c Release -o out

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build-env /app/out .
# Ensure the ClientApp/dist folder is copied to the runtime image
COPY --from=build-env /app/ClientApp/dist ./ClientApp/dist

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "WebhookApp.dll"]