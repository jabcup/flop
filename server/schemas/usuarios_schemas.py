from pydantic import BaseModel, Field
# from pydantic import EmailStr  # descomentar si se instala email-validator


class UsuarioBase(BaseModel):
    nombre: str = Field(max_length=100)
    email: str = Field(max_length=255)  # o EmailStr si se instala la dependencia


class UsuarioRegistrar(UsuarioBase):
    clave: str = Field(max_length=255, min_length=5)


class UsuarioAcceder(BaseModel):
    email: str = Field(max_length=255)
    clave: str = Field(max_length=255)


class UsuarioActualizar(BaseModel):
    nombre: str = Field(max_length=100)
    email: str = Field(max_length=255)  # o EmailStr


class CambiarClave(BaseModel):
    clave_actual: str = Field(max_length=255)
    clave_nueva: str = Field(max_length=255, min_length=5)
