using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Globalization;

namespace ACEXAPI.ModelBinders;

/// <summary>
/// Model binder personalizado para decimales que usa InvariantCulture
/// para evitar problemas con separadores decimales según configuración regional
/// </summary>
public class DecimalModelBinder : IModelBinder
{
    public Task BindModelAsync(ModelBindingContext bindingContext)
    {
        if (bindingContext == null)
        {
            throw new ArgumentNullException(nameof(bindingContext));
        }

        var modelName = bindingContext.ModelName;
        var valueProviderResult = bindingContext.ValueProvider.GetValue(modelName);

        if (valueProviderResult == ValueProviderResult.None)
        {
            return Task.CompletedTask;
        }

        bindingContext.ModelState.SetModelValue(modelName, valueProviderResult);

        var value = valueProviderResult.FirstValue;

        if (string.IsNullOrEmpty(value))
        {
            return Task.CompletedTask;
        }

        // Intentar parsear usando InvariantCulture (punto como decimal)
        if (decimal.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out var result))
        {
            bindingContext.Result = ModelBindingResult.Success(result);
        }
        else
        {
            // Si falla, intentar con CurrentCulture como fallback
            if (decimal.TryParse(value, NumberStyles.Any, CultureInfo.CurrentCulture, out result))
            {
                bindingContext.Result = ModelBindingResult.Success(result);
            }
            else
            {
                bindingContext.ModelState.TryAddModelError(
                    modelName,
                    $"El valor '{value}' no es válido para el tipo decimal.");
            }
        }

        return Task.CompletedTask;
    }
}

/// <summary>
/// Provider del model binder personalizado
/// </summary>
public class DecimalModelBinderProvider : IModelBinderProvider
{
    public IModelBinder? GetBinder(ModelBinderProviderContext context)
    {
        if (context == null)
        {
            throw new ArgumentNullException(nameof(context));
        }

        if (context.Metadata.ModelType == typeof(decimal) || 
            context.Metadata.ModelType == typeof(decimal?))
        {
            return new DecimalModelBinder();
        }

        return null;
    }
}
