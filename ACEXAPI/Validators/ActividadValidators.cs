using ACEXAPI.DTOs;
using FluentValidation;

namespace ACEXAPI.Validators;

public class ActividadCreateDtoValidator : AbstractValidator<ActividadCreateDto>
{
    public ActividadCreateDtoValidator()
    {
        RuleFor(x => x.Nombre)
            .NotEmpty().WithMessage("El nombre es requerido")
            .MaximumLength(200).WithMessage("El nombre no puede exceder 200 caracteres");

        RuleFor(x => x.Descripcion)
            .MaximumLength(1000).WithMessage("La descripción no puede exceder 1000 caracteres");

        RuleFor(x => x.FechaInicio)
            .NotEmpty().WithMessage("La fecha de inicio es requerida")
            .GreaterThanOrEqualTo(DateTime.Today.AddDays(-30))
            .WithMessage("La fecha de inicio no puede ser anterior a 30 días");

        RuleFor(x => x.FechaFin)
            .GreaterThanOrEqualTo(x => x.FechaInicio)
            .When(x => x.FechaFin.HasValue)
            .WithMessage("La fecha de fin debe ser posterior a la fecha de inicio");

        RuleFor(x => x.PresupuestoEstimado)
            .GreaterThan(0).When(x => x.PresupuestoEstimado.HasValue)
            .WithMessage("El presupuesto debe ser mayor a 0");
    }
}

public class ActividadUpdateDtoValidator : AbstractValidator<ActividadUpdateDto>
{
    public ActividadUpdateDtoValidator()
    {
        RuleFor(x => x.Nombre)
            .MaximumLength(200).When(x => !string.IsNullOrEmpty(x.Nombre))
            .WithMessage("El nombre no puede exceder 200 caracteres");

        RuleFor(x => x.Descripcion)
            .MaximumLength(1000).When(x => !string.IsNullOrEmpty(x.Descripcion))
            .WithMessage("La descripción no puede exceder 1000 caracteres");

        RuleFor(x => x.PresupuestoEstimado)
            .GreaterThan(0).When(x => x.PresupuestoEstimado.HasValue)
            .WithMessage("El presupuesto debe ser mayor a 0");

        RuleFor(x => x.CostoReal)
            .GreaterThan(0).When(x => x.CostoReal.HasValue)
            .WithMessage("El costo real debe ser mayor a 0");
    }
}
