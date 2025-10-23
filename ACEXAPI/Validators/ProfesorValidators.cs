using ACEXAPI.DTOs;
using FluentValidation;

namespace ACEXAPI.Validators;

public class ProfesorCreateDtoValidator : AbstractValidator<ProfesorCreateDto>
{
    public ProfesorCreateDtoValidator()
    {
        RuleFor(x => x.Dni)
            .NotEmpty().WithMessage("El DNI es requerido")
            .Matches(@"^\d{8}[A-Za-z]$").WithMessage("El DNI debe tener 8 dígitos seguidos de una letra");

        RuleFor(x => x.Nombre)
            .NotEmpty().WithMessage("El nombre es requerido")
            .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres");

        RuleFor(x => x.Apellidos)
            .NotEmpty().WithMessage("Los apellidos son requeridos")
            .MaximumLength(100).WithMessage("Los apellidos no pueden exceder 100 caracteres");

        RuleFor(x => x.Correo)
            .NotEmpty().WithMessage("El correo es requerido")
            .EmailAddress().WithMessage("El correo no es válido")
            .MaximumLength(200).WithMessage("El correo no puede exceder 200 caracteres");

        RuleFor(x => x.Telefono)
            .Matches(@"^\d{9}$").When(x => !string.IsNullOrEmpty(x.Telefono))
            .WithMessage("El teléfono debe tener 9 dígitos");
    }
}

public class ProfesorUpdateDtoValidator : AbstractValidator<ProfesorUpdateDto>
{
    public ProfesorUpdateDtoValidator()
    {
        RuleFor(x => x.Nombre)
            .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.Nombre))
            .WithMessage("El nombre no puede exceder 100 caracteres");

        RuleFor(x => x.Apellidos)
            .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.Apellidos))
            .WithMessage("Los apellidos no pueden exceder 100 caracteres");

        RuleFor(x => x.Telefono)
            .Matches(@"^\d{9}$").When(x => !string.IsNullOrEmpty(x.Telefono))
            .WithMessage("El teléfono debe tener 9 dígitos");
    }
}
