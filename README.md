# 📐 AMI · Ejercicio interactivo en clase

App en Streamlit para tomar ejercicios en clase de **Análisis Matemático I**. Los estudiantes responden preguntas de opción múltiple y reciben feedback inmediato; el docente accede a estadísticas en tiempo real.

## Funcionalidades

- **Estudiantes** — login por nombre + DNI, responden preguntas secuenciales, ven la respuesta correcta y una explicación al instante, historial en sidebar.
- **Docente** — login por email, ve porcentajes de aciertos por pregunta, distribución de respuestas, historial por alumno y exportación CSV.
- Una sola respuesta por pregunta por estudiante.

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Streamlit |
| Base de datos | Supabase (PostgreSQL) |
| Autenticación | Tabla SQL propia (sin Auth de Supabase) |

## Estructura

```
app.py            # App principal
tablas.sql        # DDL + preguntas precargadas (40 preguntas)
requirements.txt  # Dependencias
tokens.py         # Credenciales locales (en .gitignore)
.streamlit/
  secrets.toml    # Credenciales para Streamlit Cloud (en .gitignore)
```

## Preguntas incluidas

| Órdenes | Tema |
|---|---|
| 1–6 | Términos y propiedad distributiva |
| 7–30 | Álgebra básica (exponentes, radicales, factorización, racionales) |
| 31–40 | Análisis Matemático I (límites, continuidad, derivadas) |

## Deploy local

```bash
pip install -r requirements.txt
streamlit run app.py
```

## Deploy en Streamlit Cloud

1. Ejecutar `tablas.sql` en el **SQL Editor** de Supabase.
2. En Streamlit Cloud → **Settings → Secrets**, agregar:
```toml
supabase_id = "..."
supabase_key = "..."
```
3. Deploy desde `main`, entry point `app.py`.
