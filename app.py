import streamlit as st
from supabase import create_client, Client
import pandas as pd

# Credenciales: Streamlit Cloud usa st.secrets, localmente cae a tokens.py
try:
    supabase_id = st.secrets["supabase_id"]
    supbase_key = st.secrets["supabase_key"]
except Exception:
    try:
        from tokens import supbase_key, supabase_id
    except ImportError:
        st.error("❌ No se encontraron credenciales de Supabase. "
                 "Configurá los secrets en Streamlit Cloud o creá tokens.py localmente.")
        st.stop()

# ──────────────────────────────────────────────
# Configuración de página y conexión
# ──────────────────────────────────────────────
st.set_page_config(
    page_title="AMI · Ejercicio en clase",
    page_icon="📐",
    layout="centered",
)

SUPABASE_URL = f"https://{supabase_id}.supabase.co"
ADMIN_EMAIL  = "facundo@pymetech.com.ar"

COLOR_OK   = "#2ecc71"
COLOR_MAL  = "#e74c3c"
COLOR_INFO = "#3498db"

@st.cache_resource
def get_supabase() -> Client:
    return create_client(SUPABASE_URL, supbase_key)

supabase = get_supabase()

# ──────────────────────────────────────────────
# Utilidades de base de datos
# ──────────────────────────────────────────────

def obtener_usuario_por_dni(dni: str):
    res = supabase.table("usuarios").select("*").eq("dni", dni).execute()
    return res.data[0] if res.data else None

def obtener_usuario_por_email(email: str):
    res = supabase.table("usuarios").select("*").eq("email", email).execute()
    return res.data[0] if res.data else None

def crear_estudiante(nombre: str, dni: str):
    res = supabase.table("usuarios").insert({
        "nombre": nombre,
        "dni": dni,
        "rol": "estudiante"
    }).execute()
    return res.data[0] if res.data else None

def obtener_preguntas():
    res = (
        supabase.table("preguntas")
        .select("*")
        .eq("activa", True)
        .order("orden")
        .execute()
    )
    return res.data

def obtener_respuestas_usuario(usuario_id: int):
    res = (
        supabase.table("respuestas")
        .select("*, preguntas(enunciado, respuesta_correcta, explicacion, opcion_a, opcion_b, opcion_c, opcion_d, orden)")
        .eq("usuario_id", usuario_id)
        .execute()
    )
    return res.data

def guardar_respuesta(usuario_id: int, pregunta_id: int, elegida: str, correcta: str):
    es_correcta = (elegida == correcta)
    supabase.table("respuestas").upsert({
        "usuario_id": usuario_id,
        "pregunta_id": pregunta_id,
        "respuesta_elegida": elegida,
        "es_correcta": es_correcta,
    }, on_conflict="usuario_id,pregunta_id").execute()
    return es_correcta

def obtener_todas_respuestas():
    res = (
        supabase.table("respuestas")
        .select("*, usuarios(nombre, dni), preguntas(enunciado, respuesta_correcta, orden)")
        .execute()
    )
    return res.data

# ──────────────────────────────────────────────
# Helpers de UI
# ──────────────────────────────────────────────

LETRAS = {"A": 0, "B": 1, "C": 2, "D": 3}

def texto_opcion(pregunta: dict, letra: str) -> str:
    mapa = {"A": "opcion_a", "B": "opcion_b", "C": "opcion_c", "D": "opcion_d"}
    return f"**{letra})** {pregunta[mapa[letra]]}"

def opciones_radio(pregunta: dict) -> list[str]:
    return [
        f"A) {pregunta['opcion_a']}",
        f"B) {pregunta['opcion_b']}",
        f"C) {pregunta['opcion_c']}",
        f"D) {pregunta['opcion_d']}",
    ]

# ──────────────────────────────────────────────
# VISTAS
# ──────────────────────────────────────────────

def vista_login():
    st.title("📐 Análisis Matemático I")
    st.subheader("Ejercicio interactivo en clase")
    st.markdown("---")

    tab_est, tab_admin = st.tabs(["🎓 Soy estudiante", "🔑 Acceso docente"])

    # --- TAB ESTUDIANTE ---
    with tab_est:
        st.markdown("#### Ingresá tu nombre y DNI para comenzar")
        nombre = st.text_input("Nombre completo", key="login_nombre")
        dni    = st.text_input("DNI (sin puntos)", key="login_dni")

        if st.button("Ingresar", key="btn_est", type="primary"):
            nombre = nombre.strip()
            dni    = dni.strip()

            if not nombre or not dni:
                st.warning("Completá nombre y DNI.")
                return

            usuario = obtener_usuario_por_dni(dni)

            if usuario is None:
                # Nuevo estudiante
                usuario = crear_estudiante(nombre, dni)
                if usuario:
                    st.success(f"¡Bienvenido/a {nombre}! Tu cuenta fue creada.")
                else:
                    st.error("Error al crear usuario. Intentá de nuevo.")
                    return
            elif usuario["rol"] == "admin":
                st.error("Ese DNI corresponde a una cuenta de docente.")
                return
            else:
                st.success(f"¡Bienvenido/a de nuevo, {usuario['nombre']}!")

            st.session_state["usuario"] = usuario
            st.session_state["pregunta_idx"] = 0
            st.rerun()

    # --- TAB ADMIN ---
    with tab_admin:
        st.markdown("#### Ingresá tu e-mail de docente")
        email = st.text_input("E-mail", key="login_email")

        if st.button("Ingresar", key="btn_admin", type="primary"):
            email = email.strip().lower()
            usuario = obtener_usuario_por_email(email)

            if usuario and usuario["rol"] == "admin":
                st.success(f"Bienvenido/a, {usuario['nombre']}.")
                st.session_state["usuario"] = usuario
                st.rerun()
            else:
                st.error("E-mail no autorizado.")


def vista_estudiante():
    usuario   = st.session_state["usuario"]
    preguntas = obtener_preguntas()

    if not preguntas:
        st.warning("No hay preguntas activas cargadas todavía.")
        return

    # Sidebar: info del estudiante + historial
    with st.sidebar:
        st.markdown(f"### 👤 {usuario['nombre']}")
        st.caption(f"DNI: {usuario['dni']}")
        st.markdown("---")

        respuestas_hist = obtener_respuestas_usuario(usuario["id"])
        ids_respondidas = {r["pregunta_id"] for r in respuestas_hist}
        total = len(preguntas)
        respondidas = len(ids_respondidas)
        correctas_n = sum(1 for r in respuestas_hist if r["es_correcta"])

        st.metric("Progreso", f"{respondidas}/{total}")
        if respondidas > 0:
            st.metric("Correctas", f"{correctas_n}/{respondidas}",
                      delta=f"{correctas_n/respondidas*100:.0f}%")

        st.markdown("---")

        # Historial de respuestas
        if respuestas_hist:
            st.markdown("#### 📋 Mis respuestas")
            for r in sorted(respuestas_hist,
                            key=lambda x: x["preguntas"]["orden"] if x.get("preguntas") else 0):
                icono = "✅" if r["es_correcta"] else "❌"
                enun  = r["preguntas"]["enunciado"] if r.get("preguntas") else "—"
                st.markdown(f"{icono} _{enun[:55]}…_")

        st.markdown("---")
        if st.button("Cerrar sesión"):
            st.session_state.clear()
            st.rerun()

    # ── Cuerpo principal ──
    st.title("📐 Análisis Matemático I")

    # Barra de navegación entre preguntas
    idx = st.session_state.get("pregunta_idx", 0)
    idx = max(0, min(idx, len(preguntas) - 1))

    cols_nav = st.columns([1, 8, 1])
    with cols_nav[0]:
        if st.button("◀", disabled=(idx == 0)):
            st.session_state["pregunta_idx"] = idx - 1
            st.rerun()
    with cols_nav[1]:
        st.markdown(f"<center><b>Pregunta {idx+1} de {len(preguntas)}</b></center>",
                    unsafe_allow_html=True)
    with cols_nav[2]:
        if st.button("▶", disabled=(idx == len(preguntas) - 1)):
            st.session_state["pregunta_idx"] = idx + 1
            st.rerun()

    st.markdown("---")
    pregunta = preguntas[idx]
    ya_respondio = pregunta["id"] in ids_respondidas

    # Enunciado
    st.markdown(f"### {pregunta['enunciado']}")

    # Opciones
    opciones = opciones_radio(pregunta)

    if ya_respondio:
        # Mostrar respuesta ya dada + resultado
        resp_data = next((r for r in respuestas_hist if r["pregunta_id"] == pregunta["id"]), None)
        elegida   = resp_data["respuesta_elegida"] if resp_data else "?"
        correcta  = pregunta["respuesta_correcta"]

        for op in opciones:
            letra = op[0]
            if letra == correcta:
                st.success(f"✅ {op}")
            elif letra == elegida and elegida != correcta:
                st.error(f"❌ {op}  ← tu respuesta")
            else:
                st.markdown(f"- {op}")

        if resp_data and resp_data["es_correcta"]:
            st.markdown(
                f'<div style="background:{COLOR_OK}22;border-left:4px solid {COLOR_OK};'
                f'padding:10px;border-radius:6px;margin-top:12px">'
                f'<b>¡Correcto!</b><br>{pregunta["explicacion"]}</div>',
                unsafe_allow_html=True,
            )
        else:
            st.markdown(
                f'<div style="background:{COLOR_MAL}22;border-left:4px solid {COLOR_MAL};'
                f'padding:10px;border-radius:6px;margin-top:12px">'
                f'<b>Incorrecto.</b> La respuesta correcta era <b>{correcta}</b>.<br>'
                f'{pregunta["explicacion"]}</div>',
                unsafe_allow_html=True,
            )
    else:
        # Pregunta sin responder
        eleccion = st.radio(
            "Seleccioná tu respuesta:",
            opciones,
            index=None,
            key=f"radio_{pregunta['id']}",
        )

        if st.button("Responder", type="primary", disabled=(eleccion is None)):
            letra_elegida = eleccion[0]  # "A", "B"…
            es_correcta = guardar_respuesta(
                usuario["id"], pregunta["id"], letra_elegida, pregunta["respuesta_correcta"]
            )
            st.rerun()


def _live_stats(preg: dict, n_total_estudiantes: int):
    """Fragment que se auto-refresca cada 5 s con las estadísticas en vivo."""
    res = (
        supabase.table("respuestas")
        .select("respuesta_elegida, es_correcta, usuario_id")
        .eq("pregunta_id", preg["id"])
        .execute()
    )
    datos = res.data or []
    n_respondieron = len({r["usuario_id"] for r in datos})
    n_ok = sum(1 for r in datos if r["es_correcta"])

    # ── Métricas ──
    c1, c2, c3 = st.columns(3)
    c1.metric("Estudiantes conectados", n_total_estudiantes)
    c2.metric("Respondieron", n_respondieron)
    pct_ok = (n_ok / len(datos) * 100) if datos else 0
    c3.metric("% Correctas", f"{pct_ok:.0f}%" if datos else "—")

    st.progress(n_respondieron / n_total_estudiantes if n_total_estudiantes else 0)

    # ── Distribución de respuestas ──
    if datos:
        conteo = {"A": 0, "B": 0, "C": 0, "D": 0}
        for r in datos:
            conteo[r["respuesta_elegida"]] = conteo.get(r["respuesta_elegida"], 0) + 1

        labels = [
            f"A) {preg['opcion_a']}",
            f"B) {preg['opcion_b']}",
            f"C) {preg['opcion_c']}",
            f"D) {preg['opcion_d']}",
        ]
        valores = [conteo[l] for l in ["A","B","C","D"]]
        correcta = preg["respuesta_correcta"]

        dist_df = pd.DataFrame({
            "Opción": [f"{'✅ ' if l == correcta else ''}{lbl}"
                       for l, lbl in zip(["A","B","C","D"], labels)],
            "Respuestas": valores,
        }).set_index("Opción")

        st.bar_chart(dist_df)
    else:
        st.info("Esperando respuestas…")


def vista_admin():
    usuario = st.session_state["usuario"]

    with st.sidebar:
        st.markdown(f"### 🔑 Docente: {usuario['nombre']}")
        st.markdown("---")
        if st.button("Cerrar sesión"):
            st.session_state.clear()
            st.rerun()

    st.title("📊 Panel del Docente — AMI")

    tab_clase, tab_analisis = st.tabs(["🎓 Modo Clase  (Live)", "📊 Análisis completo"])

    # ══════════════════════════════════════════
    # TAB 1 — MODO CLASE EN VIVO
    # ══════════════════════════════════════════
    with tab_clase:
        preguntas_objs = obtener_preguntas()
        if not preguntas_objs:
            st.info("No hay preguntas activas cargadas.")
        else:
            preguntas_objs = sorted(preguntas_objs, key=lambda p: p["orden"])

            # Número de estudiantes conectados (cualquier usuario que haya respondido al menos 1)
            res_usuarios = supabase.table("respuestas").select("usuario_id").execute()
            n_total_est = len({r["usuario_id"] for r in (res_usuarios.data or [])})

            # Navegación de pregunta
            if "admin_q_idx" not in st.session_state:
                st.session_state["admin_q_idx"] = 0

            idx = st.session_state["admin_q_idx"]
            idx = max(0, min(idx, len(preguntas_objs) - 1))

            st.markdown("### Pregunta actual")
            nav1, nav2, nav3 = st.columns([1, 8, 1])
            with nav1:
                if st.button("◀", key="adm_prev", disabled=(idx == 0)):
                    st.session_state["admin_q_idx"] = idx - 1
                    st.rerun()
            with nav2:
                st.markdown(
                    f"<center><b>Pregunta {idx + 1} de {len(preguntas_objs)}</b></center>",
                    unsafe_allow_html=True,
                )
            with nav3:
                if st.button("▶", key="adm_next", disabled=(idx == len(preguntas_objs) - 1)):
                    st.session_state["admin_q_idx"] = idx + 1
                    st.rerun()

            preg = preguntas_objs[idx]

            # Enunciado + opciones
            st.markdown("---")
            st.markdown(f"#### {preg['enunciado']}")
            for letra, campo in zip(["A","B","C","D"],
                                    ["opcion_a","opcion_b","opcion_c","opcion_d"]):
                marker = "✅ " if letra == preg["respuesta_correcta"] else ""
                st.markdown(f"- **{letra})** {marker}{preg[campo]}")

            st.markdown("---")
            st.markdown("#### 📡 Respuestas en vivo")

            # Botón de refresco manual + auto-refresco con fragment
            col_ref, _ = st.columns([1, 5])
            with col_ref:
                if st.button("🔄 Actualizar", key="adm_refresh"):
                    st.rerun()

            # Fragment con auto-refresco cada 5 segundos
            @st.fragment(run_every=5)
            def live_block():
                _live_stats(preg, n_total_est)

            live_block()

    # ══════════════════════════════════════════
    # TAB 2 — ANÁLISIS COMPLETO
    # ══════════════════════════════════════════
    with tab_analisis:
        todas = obtener_todas_respuestas()

        if not todas:
            st.info("Aún no hay respuestas registradas.")
            return

        df = pd.DataFrame(todas)

        # Aplanar columnas anidadas
        df["nombre_est"]    = df["usuarios"].apply(lambda u: u["nombre"] if u else "—")
        df["dni_est"]       = df["usuarios"].apply(lambda u: u["dni"]    if u else "—")
        df["enunciado"]     = df["preguntas"].apply(lambda p: p["enunciado"][:60] + "…" if p else "—")
        df["orden_preg"]    = df["preguntas"].apply(lambda p: p["orden"] if p else 0)
        df["resp_correcta"] = df["preguntas"].apply(lambda p: p["respuesta_correcta"] if p else "?")

        # ── Métricas globales ──
        col1, col2, col3 = st.columns(3)
        n_estudiantes = df["usuario_id"].nunique()
        total_resp    = len(df)
        pct_ok        = df["es_correcta"].mean() * 100

        col1.metric("Estudiantes", n_estudiantes)
        col2.metric("Respuestas totales", total_resp)
        col3.metric("% Correctas global", f"{pct_ok:.1f}%")

        st.markdown("---")

        # ── Estadísticas por pregunta ──
        st.subheader("📌 Estadísticas por pregunta")

        preguntas_all = obtener_preguntas()
        for preg in sorted(preguntas_all, key=lambda p: p["orden"]):
            df_p = df[df["pregunta_id"] == preg["id"]]
            if df_p.empty:
                continue

            n_total  = len(df_p)
            n_ok     = df_p["es_correcta"].sum()
            pct_preg = n_ok / n_total * 100

            with st.expander(f"P{preg['orden']}. {preg['enunciado'][:70]}…  —  {pct_preg:.0f}% correctas"):
                dist     = df_p["respuesta_elegida"].value_counts().reindex(["A","B","C","D"], fill_value=0)
                dist_pct = (dist / n_total * 100).round(1)

                dist_df = pd.DataFrame({
                    "Opción": [
                        f"A) {preg['opcion_a']}",
                        f"B) {preg['opcion_b']}",
                        f"C) {preg['opcion_c']}",
                        f"D) {preg['opcion_d']}",
                    ],
                    "Respuestas": dist.values,
                    "% del total": dist_pct.values,
                    "Correcta": ["✅" if l == preg["respuesta_correcta"] else "" for l in ["A","B","C","D"]],
                })
                st.dataframe(dist_df, use_container_width=True, hide_index=True)
                st.bar_chart(dist_pct, y_label="% estudiantes")

        st.markdown("---")

        # ── Historial por estudiante ──
        st.subheader("👥 Historial por estudiante")

        estudiantes = df[["usuario_id","nombre_est","dni_est"]].drop_duplicates()
        for _, row in estudiantes.iterrows():
            df_est = df[df["usuario_id"] == row["usuario_id"]].sort_values("orden_preg")
            n_ok   = df_est["es_correcta"].sum()
            n_tot  = len(df_est)

            with st.expander(f"**{row['nombre_est']}** — DNI {row['dni_est']}  |  {n_ok}/{n_tot} correctas"):
                tabla = df_est[["enunciado","respuesta_elegida","resp_correcta","es_correcta"]].copy()
                tabla.columns = ["Pregunta","Elegida","Correcta","¿Acertó?"]
                tabla["¿Acertó?"] = tabla["¿Acertó?"].map({True: "✅", False: "❌"})
                st.dataframe(tabla, use_container_width=True, hide_index=True)

        st.markdown("---")

        # ── Tabla completa descargable ──
        st.subheader("⬇️ Exportar datos")
        export_df = df[["nombre_est","dni_est","enunciado","respuesta_elegida",
                        "resp_correcta","es_correcta","created_at"]].copy()
        export_df.columns = ["Nombre","DNI","Pregunta","Respuesta elegida",
                             "Respuesta correcta","Correcto","Fecha"]
        export_df["Correcto"] = export_df["Correcto"].map({True: "Sí", False: "No"})

        csv = export_df.to_csv(index=False).encode("utf-8")
        st.download_button(
            "Descargar CSV completo",
            data=csv,
            file_name="respuestas_ami.csv",
            mime="text/csv",
        )


# ──────────────────────────────────────────────
# Router principal
# ──────────────────────────────────────────────

def main():
    usuario = st.session_state.get("usuario")

    if usuario is None:
        vista_login()
    elif usuario["rol"] == "admin":
        vista_admin()
    else:
        vista_estudiante()


if __name__ == "__main__":
    main()
