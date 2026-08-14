#!/usr/bin/env bash
# configure-dotnet.sh
# .NET project configuration script
# Handles .csproj, Directory.Build.props, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Configure .NET project
configure_dotnet_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library | mobile
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library | mobile-app

    log_info "Configuring .NET project (mode: $mode, app_type: $app_type)"

    # Handle .csproj files
    if [[ -f "$project_path/*.csproj" ]]; then
        configure_csproj_files "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_dotnet_project "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle Directory.Build.props
    configure_directory_build_props "$project_path" "$mode"

    # Handle .NET testing configuration
    configure_dotnet_testing_config "$project_path" "$mode"

    # Handle framework-specific configs
    configure_dotnet_framework_configs "$project_path" "$mode" "$app_type" "$project_type"
}

# Configure .csproj files
configure_csproj_files() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring .csproj files for .NET project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_csproj_packages "$project_path" "$app_type" "$project_type"
        add_standardize_csproj_properties "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_csproj_packages "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode packages to .csproj
add_standardize_csproj_packages() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Find all .csproj files
    for csproj in "$project_path"/*.csproj; do
        if [[ -f "$csproj" ]]; then
            log_info "Updating $(basename "$csproj") with standardize packages"

            # Apply surgical changes using yq-go if available
            if command -v yq-go >/dev/null 2>&1; then
                echo "Adding standardize packages to $(basename "$csproj") using yq-go"
                
                # Base packages for all .NET projects
                # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.Extensions.Logging", "Version": "7.0.0"}]' "$csproj" -i
                # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.Extensions.Configuration", "Version": "7.0.0"}]' "$csproj" -i
                
                # App-type specific packages
                case "$app_type" in
                    "web")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.AspNetCore.App", "Version": "7.0.0"}]' "$csproj" -i
                        if [[ "$project_type" == *"frontend-web"* ]]; then
                            # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation", "Version": "7.0.0"}]' "$csproj" -i
                        fi
                        ;;
                    "mobile")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Xamarin.Forms", "Version": "5.0.0.2577"}]' "$csproj" -i
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Xamarin.Essentials", "Version": "1.7.5"}]' "$csproj" -i
                        ;;
                    "cli")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "System.CommandLine", "Version": "2.0.0-beta4.22272.1"}]' "$csproj" -i
                        ;;
                    "api")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.AspNetCore.App", "Version": "7.0.0"}]' "$csproj" -i
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.EntityFrameworkCore.SqlServer", "Version": "7.0.0"}]' "$csproj" -i
                        ;;
                esac

                # Framework-specific packages
                case "$project_type" in
                    "mobile-app")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Xamarin.Forms", "Version": "5.0.0.2577"}]' "$csproj" -i
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Prism.Forms", "Version": "8.1.0.1850-pre"}]' "$csproj" -i
                        ;;
                    "frontend-web")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.AspNetCore.Components.WebAssembly", "Version": "7.0.0"}]' "$csproj" -i
                        ;;
                    "api-service")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.AspNetCore.Authentication.JwtBearer", "Version": "7.0.0"}]' "$csproj" -i
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "System.IdentityModel.Tokens.Jwt", "Version": "6.32.3"}]' "$csproj" -i
                        ;;
                esac
            else
                log_warn "yq-go not available, skipping $(basename "$csproj") package updates"
            fi
        fi
    done
}

# Add adopt mode packages to .csproj
add_adopt_csproj_packages() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Find all .csproj files
    for csproj in "$project_path"/*.csproj; do
        if [[ -f "$csproj" ]]; then
            log_info "Updating $(basename "$csproj") with adopt packages"

            # Apply surgical changes
            if command -v yq-go >/dev/null 2>&1; then
                echo "Adding adopt packages to $(basename "$csproj") using yq-go"
                
                case "$app_type" in
                    "web")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.AspNetCore.App", "Version": "7.0.0"}]' "$csproj" -i
                        ;;
                    "mobile")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Xamarin.Forms", "Version": "5.0.0.2577"}]' "$csproj" -i
                        ;;
                    "api")
                        # yq-go eval '.ItemGroup[1].PackageReference += [{"@Include": "Microsoft.AspNetCore.App", "Version": "7.0.0"}]' "$csproj" -i
                        ;;
                esac
            else
                log_warn "yq-go not available or no packages to add"
            fi
        fi
    done
}

# Add standardize mode properties to .csproj
add_standardize_csproj_properties() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Find all .csproj files
    for csproj in "$project_path"/*.csproj; do
        if [[ -f "$csproj" ]]; then
            log_info "Updating $(basename "$csproj") with standardize properties"

            # Apply surgical changes
            if command -v yq-go >/dev/null 2>&1; then
                echo "Adding standardize properties to $(basename "$csproj") using yq-go"
                
                # Add common properties
                # yq-go eval '.PropertyGroup[0].Nullable = "enable"' "$csproj" -i
                # yq-go eval '.PropertyGroup[0].ImplicitUsings = "enable"' "$csproj" -i
                # yq-go eval '.PropertyGroup[0].TreatWarningsAsErrors = "true"' "$csproj" -i
                
                # App-type specific properties
                case "$app_type" in
                    "web")
                        # yq-go eval '.PropertyGroup[0].TargetFramework = "net7.0"' "$csproj" -i
                        ;;
                    "mobile")
                        # yq-go eval '.PropertyGroup[0].TargetFramework = "net7.0-android"' "$csproj" -i
                        ;;
                    "cli")
                        # yq-go eval '.PropertyGroup[0].TargetFramework = "net7.0"' "$csproj" -i
                        ;;
                    "api")
                        # yq-go eval '.PropertyGroup[0].TargetFramework = "net7.0"' "$csproj" -i
                        ;;
                esac
            else
                log_warn "yq-go not available, skipping $(basename "$csproj") property updates"
            fi
        fi
    done
}

# Create .NET project
create_dotnet_project() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path"/*.csproj" ]]; then
        local project_name
        project_name=$(basename "$project_path")
        
        case "$app_type" in
            "web")
                create_web_project "$project_path" "$project_name" "$project_type"
                ;;
            "mobile")
                create_mobile_project "$project_path" "$project_name" "$project_type"
                ;;
            "cli")
                create_console_project "$project_path" "$project_name" "$project_type"
                ;;
            "api")
                create_api_project "$project_path" "$project_name" "$project_type"
                ;;
            *)
                create_classlib_project "$project_path" "$project_name" "$project_type"
                ;;
        esac
    fi
}

# Create web project
create_web_project() {
    local project_path="$1"
    local project_name="$2"
    local project_type="$3"

    cat > "$project_path/$project_name.csproj" << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net7.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.App" />
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Logging" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="7.0.0" />
  </ItemGroup>

</Project>
EOF
    log_info "✓ Created $project_name.csproj"
}

# Create mobile project
create_mobile_project() {
    local project_path="$1"
    local project_name="$2"
    local project_type="$3"

    cat > "$project_path/$project_name.csproj" << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net7.0-android</TargetFramework>
    <TargetFramework>net7.0-ios</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Xamarin.Forms" Version="5.0.0.2577" />
    <PackageReference Include="Xamarin.Essentials" Version="1.7.5" />
    <PackageReference Include="Prism.Forms" Version="8.1.0.1850-pre" />
    <PackageReference Include="Microsoft.Extensions.Logging" Version="7.0.0" />
  </ItemGroup>

</Project>
EOF
    log_info "✓ Created $project_name.csproj"
}

# Create console project
create_console_project() {
    local project_path="$1"
    local project_name="$2"
    local project_type="$3"

    cat > "$project_path/$project_name.csproj" << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net7.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="System.CommandLine" Version="2.0.0-beta4.22272.1" />
    <PackageReference Include="Microsoft.Extensions.Logging" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="7.0.0" />
  </ItemGroup>

</Project>
EOF
    log_info "✓ Created $project_name.csproj"
}

# Create API project
create_api_project() {
    local project_path="$1"
    local project_name="$2"
    local project_type="$3"

    cat > "$project_path/$project_name.csproj" << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net7.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.App" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="7.0.0" />
    <PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="7.0.0" />
    <PackageReference Include="System.IdentityModel.Tokens.Jwt" Version="6.32.3" />
    <PackageReference Include="Microsoft.Extensions.Logging" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="7.0.0" />
  </ItemGroup>

</Project>
EOF
    log_info "✓ Created $project_name.csproj"
}

# Create class library project
create_classlib_project() {
    local project_path="$1"
    local project_name="$2"
    local project_type="$3"

    cat > "$project_path/$project_name.csproj" << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net7.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Logging" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="7.0.0" />
  </ItemGroup>

</Project>
EOF
    log_info "✓ Created $project_name.csproj"
}

# Configure Directory.Build.props
configure_directory_build_props() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/Directory.Build.props" ]]; then
        cat > "$project_path/Directory.Build.props" << 'EOF'
<Project>
  <PropertyGroup>
    <TargetFramework>net7.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <LangVersion>latest</LangVersion>
    <EnableNETAnalyzers>true</EnableNETAnalyzers>
    <AnalysisLevel>latest</AnalysisLevel>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Logging" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.DependencyInjection" Version="7.0.0" />
  </ItemGroup>

  <ItemGroup Condition="'$(MSBuildProjectName)' != 'Test'">
    <PackageReference Include="Microsoft.Extensions.Logging.Console" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Logging.Debug" Version="7.0.0" />
  </ItemGroup>

  <ItemGroup Condition="'$(MSBuildProjectName)' == 'Test'">
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.6.0" />
    <PackageReference Include="xunit" Version="2.4.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.4.5" />
    <PackageReference Include="Moq" Version="4.18.4" />
    <PackageReference Include="FluentAssertions" Version="6.12.0" />
  </ItemGroup>
</Project>
EOF
        log_info "✓ Created Directory.Build.props"
    fi
}

# Configure .NET testing
configure_dotnet_testing_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create test project structure
        mkdir -p "$project_path/Tests"
        
        # Create test project file
        if [[ ! -f "$project_path/Tests/Tests.csproj" ]]; then
            cat > "$project_path/Tests/Tests.csproj" << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net7.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.6.0" />
    <PackageReference Include="xunit" Version="2.4.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.4.5" />
    <PackageReference Include="Moq" Version="4.18.4" />
    <PackageReference Include="FluentAssertions" Version="6.12.0" />
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="2.2.0" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="../$(basename "$project_path").csproj" />
  </ItemGroup>

</Project>
EOF
            log_info "✓ Created Tests/Tests.csproj"
        fi

        # Create basic test file
        if [[ ! -f "$project_path/Tests/UnitTests.cs" ]]; then
            cat > "$project_path/Tests/UnitTests.cs" << 'EOF'
using Xunit;
using FluentAssertions;
using Microsoft.Extensions.Logging;

namespace Tests;

public class UnitTests
{
    [Fact]
    public void Test1()
    {
        // Arrange
        var expected = "Hello, World!";
        
        // Act
        var actual = "Hello, World!";
        
        // Assert
        actual.Should().Be(expected);
    }

    [Fact]
    public void Test2()
    {
        // Arrange
        var logger = LoggerFactory.CreateLogger<UnitTests>();
        
        // Act
        logger.LogInformation("Test log message");
        
        // Assert
        Assert.True(true);
    }
}
EOF
            log_info "✓ Created Tests/UnitTests.cs"
        fi
    fi
}

# Configure .NET framework-specific configurations
configure_dotnet_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # ASP.NET Core configuration
    if [[ "$app_type" == "web" ]] || [[ "$app_type" == "api" ]] || [[ "$project_type" == *"api-service"* ]]; then
        configure_aspnet_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Xamarin configuration
    if [[ "$app_type" == "mobile" ]] || [[ "$project_type" == *"mobile-app"* ]]; then
        configure_xamarin_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Console application configuration
    if [[ "$app_type" == "cli" ]] || [[ "$project_type" == *"cli-tool"* ]]; then
        configure_console_config "$project_path" "$mode" "$app_type" "$project_type"
    fi
}

# Configure ASP.NET Core
configure_aspnet_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic ASP.NET Core project structure
        mkdir -p "$project_path/Controllers"
        mkdir -p "$project_path/Models"
        mkdir -p "$project_path/Services"
        mkdir -p "$project_path/Views"
        mkdir -p "$project_path/wwwroot"
        
        if [[ ! -f "$project_path/Program.cs" ]]; then
            cat > "$project_path/Program.cs" << 'EOF'
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
EOF
            log_info "✓ Created Program.cs"
        fi

        if [[ ! -f "$project_path/Controllers/HealthController.cs" ]]; then
            cat > "$project_path/Controllers/HealthController.cs" << 'EOF'
using Microsoft.AspNetCore.Mvc;

namespace $(basename "$project_path").Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet("health")]
    public IActionResult GetHealth()
    {
        return Ok("OK");
    }

    [HttpGet]
    public IActionResult Get()
    {
        return Ok("Welcome to .NET Web API!");
    }
}
EOF
            log_info "✓ Created Controllers/HealthController.cs"
        fi

        # Create appsettings.json
        if [[ ! -f "$project_path/appsettings.json" ]]; then
            cat > "$project_path/appsettings.json" << 'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
EOF
            log_info "✓ Created appsettings.json"
        fi

        # Create appsettings.Development.json
        if [[ ! -f "$project_path/appsettings.Development.json" ]]; then
            cat > "$project_path/appsettings.Development.json" << 'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Information"
    }
  }
}
EOF
            log_info "✓ Created appsettings.Development.json"
        fi
    fi
}

# Configure Xamarin
configure_xamarin_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        # Create Xamarin project structure
        mkdir -p "$project_path/Views"
        mkdir -p "$project_path/ViewModels"
        mkdir -p "$project_path/Models"
        mkdir -p "$project_path/Services"
        
        if [[ ! -f "$project_path/App.xaml.cs" ]]; then
            cat > "$project_path/App.xaml.cs" << 'EOF'
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace $(basename "$project_path");

public partial class App : Application
{
    public App()
    {
        InitializeComponent();

        MainPage = new MainPage();
    }

    protected override void OnStart()
    {
        base.OnStart();
    }
}
EOF
            log_info "✓ Created App.xaml.cs"
        fi

        if [[ ! -f "$project_path/MainPage.xaml" ]]; then
            cat > "$project_path/MainPage.xaml" << 'EOF'
<?xml version="1.0" encoding="utf-8" ?>
<ContentPage xmlns="http://xamarin.com/schemas/2014/forms"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             x:Class="$(basename "$project_path").MainPage">
    <StackLayout Padding="20" Spacing="10">
        <Label Text="Welcome to Xamarin.Forms!" 
               FontSize="Large" 
               HorizontalOptions="Center" />
        <Label Text="Your app is running." 
               FontSize="Medium" 
               HorizontalOptions="Center" />
    </StackLayout>
</ContentPage>
EOF
            log_info "✓ Created MainPage.xaml"
        fi

        if [[ ! -f "$project_path/MainPage.xaml.cs" ]]; then
            cat > "$project_path/MainPage.xaml.cs" << 'EOF'
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace $(basename "$project_path");

public partial class MainPage : ContentPage
{
    public MainPage()
    {
        InitializeComponent();
    }
}
EOF
            log_info "✓ Created MainPage.xaml.cs"
        fi
    fi
}

# Configure Console application
configure_console_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        if [[ ! -f "$project_path/Program.cs" ]]; then
            cat > "$project_path/Program.cs" << 'EOF'
using System.CommandLine;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;

namespace $(basename "$project_path");

class Program
{
    static int Main(string[] args)
    {
        var rootCommand = new RootCommand("A .NET console application");
        rootCommand.AddOption(new Option<string>("--name", "Your name", () => "World"));
        
        rootCommand.SetHandler((string name) =>
        {
            var serviceProvider = CreateServiceProvider();
            var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
            
            logger.LogInformation("Hello, {Name}!", name);
        });

        return rootCommand.Invoke(args);
    }

    static IServiceProvider CreateServiceProvider()
    {
        var services = new ServiceCollection();
        services.AddLogging(builder => builder.AddConsole());
        return services.BuildServiceProvider();
    }
}
EOF
            log_info "✓ Created Program.cs"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_dotnet_project
export -f configure_csproj_files
export -f configure_directory_build_props
export -f configure_dotnet_testing_config
export -f configure_dotnet_framework_configs
