-- ============================================================
-- TABLAS PARA APP: Análisis Matemático I - Ejercicio en clase
-- ============================================================

-- 1. Tabla de usuarios (estudiantes + admins)
CREATE TABLE IF NOT EXISTS usuarios (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(200) UNIQUE,          -- solo para el admin
    rol VARCHAR(20) NOT NULL DEFAULT 'estudiante',  -- 'estudiante' | 'admin'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar usuario administrador inicial
INSERT INTO usuarios (nombre, dni, email, rol)
VALUES ('Facundo', '33210626', 'facundo@pymetech.com.ar', 'admin'),
('Pablo', '38403572', 'pablo.h.veron@gmail.com', 'admin')
ON CONFLICT (email) DO NOTHING;

-- 2. Tabla de preguntas
CREATE TABLE IF NOT EXISTS preguntas (
    id BIGSERIAL PRIMARY KEY,
    enunciado TEXT NOT NULL,
    opcion_a TEXT NOT NULL,
    opcion_b TEXT NOT NULL,
    opcion_c TEXT NOT NULL,
    opcion_d TEXT NOT NULL,
    respuesta_correcta CHAR(1) NOT NULL CHECK (respuesta_correcta IN ('A','B','C','D')),
    explicacion TEXT NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    orden INT DEFAULT 0
);

-- 3. Tabla de respuestas de estudiantes
CREATE TABLE IF NOT EXISTS respuestas (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    pregunta_id BIGINT NOT NULL REFERENCES preguntas(id) ON DELETE CASCADE,
    respuesta_elegida CHAR(1) NOT NULL CHECK (respuesta_elegida IN ('A','B','C','D')),
    es_correcta BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (usuario_id, pregunta_id)    -- un estudiante responde cada pregunta una sola vez
);

-- ============================================================
-- TÉRMINOS Y PROPIEDAD DISTRIBUTIVA (nivel básico)
-- ============================================================

INSERT INTO preguntas (enunciado, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, orden) VALUES

(
  '¿Cuántos términos tiene la expresión 3x² − 5x + 7?',
  '1',
  '2',
  '3',
  '4',
  'C',
  'Un término es cada parte separada por + o −. En 3x² − 5x + 7 hay tres términos: 3x², −5x y 7. El coeficiente, la variable y el exponente juntos forman un solo término.',
  1
),

(
  '¿Cómo se resuelve 3(2+4) − 2/4 + 8(4+4)?',
  '81,5',
  '82',
  '85,5',
  '80',
  'A',
  'Paso a paso: primero se resuelven los paréntesis: 3·6 − 2/4 + 8·8. Luego las multiplicaciones y la división: 18 − 0,5 + 64. Finalmente la suma/resta de izquierda a derecha: 17,5 + 64 = 81,5.',
  2
),

(
  'Aplica la propiedad distributiva: 4(3x − 2).',
  '12x − 2',
  '12x − 8',
  '7x − 6',
  '12x + 8',
  'B',
  'La propiedad distributiva dice a(b+c) = ab+ac. Aquí: 4·3x = 12x y 4·(−2) = −8. Resultado: 12x − 8. Cuidado: el 4 multiplica a AMBOS términos dentro del paréntesis.',
  3
),

(
  '¿Cuál es el resultado de −3(2x + 5)?',
  '6x + 15',
  '−6x + 15',
  '−6x − 15',
  '6x − 15',
  'C',
  '−3·2x = −6x y −3·5 = −15. Resultado: −6x − 15. Multiplicar un negativo por un positivo da negativo en ambos términos.',
  4
),

(
  'Simplifica combinando términos semejantes: 5x + 3y − 2x + y.',
  '7xy',
  '3x + 4y',
  '6x + 2y',
  '5x + 4y',
  'B',
  'Solo se pueden sumar/restar términos semejantes (misma parte literal). 5x − 2x = 3x y 3y + y = 4y. Resultado: 3x + 4y. Los términos con x y los términos con y no se mezclan entre sí.',
  5
),

(
  'Expande y simplifica: 2(x + 4) − 3(x − 1).',
  '−x + 11',
  '5x + 5',
  '−x + 5',
  '−x − 11',
  'A',
  'Distribuyendo: 2x + 8 − 3x + 3. (Atención: −3·(−1) = +3). Combinando semejantes: (2x−3x) + (8+3) = −x + 11.',
  6
);

-- ============================================================
-- EJERCICIOS DE ÁLGEBRA BÁSICA (prereq. AMI)
-- ============================================================

INSERT INTO preguntas (enunciado, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, orden) VALUES

-- ── Ejercicio 1: Evalúa sin calculadora ──────────────────────

(
  '[Álgebra 1a] ¿Cuánto vale (-3)⁴?',
  '-81',
  '81',
  '-12',
  '12',
  'B',
  '(-3)⁴ = (-3)·(-3)·(-3)·(-3). Como el exponente es par, el resultado es positivo: 81. Cuidado: la base es -3 completa porque los paréntesis la incluyen.',
  7
),

(
  '[Álgebra 1b] ¿Cuánto vale -3⁴?',
  '81',
  '-12',
  '-81',
  '12',
  'C',
  'Sin paréntesis, el exponente solo afecta al 3, no al signo negativo: -3⁴ = -(3⁴) = -(81) = -81. Es distinto a (-3)⁴ = 81.',
  8
),

(
  '[Álgebra 1c] ¿Cuánto vale 3⁻⁴?',
  '-81',
  '1/81',
  '-1/81',
  '1/12',
  'B',
  'Un exponente negativo indica el recíproco: 3⁻⁴ = 1/3⁴ = 1/81. Regla general: a⁻ⁿ = 1/aⁿ (para a ≠ 0).',
  9
),

(
  '[Álgebra 1d] ¿Cuánto vale 5²³ / 5²¹?',
  '5',
  '1',
  '5⁴⁴',
  '25',
  'D',
  'Usando la ley de exponentes aᵐ/aⁿ = aᵐ⁻ⁿ: 5²³/5²¹ = 5²³⁻²¹ = 5² = 25.',
  10
),

(
  '[Álgebra 1e] ¿Cuánto vale (2/3)⁻²?',
  '4/9',
  '-4/9',
  '9/4',
  '-9/4',
  'C',
  '(2/3)⁻² = (3/2)² = 9/4. Un exponente negativo invierte la fracción base: (a/b)⁻ⁿ = (b/a)ⁿ.',
  11
),

(
  '[Álgebra 1f] ¿Cuánto vale 16⁻³/⁴?',
  '-8',
  '1/8',
  '8',
  '-1/8',
  'B',
  '16^(3/4) = (16^(1/4))³ = 2³ = 8, entonces 16^(-3/4) = 1/8. Se calcula primero la raíz cuarta (16^(1/4) = 2) y luego se eleva al cubo.',
  12
),

-- ── Ejercicio 2: Simplifica (sin exponentes negativos) ───────

(
  '[Álgebra 2b] Simplifica (3a³b³)(4ab²)².',
  '12a⁵b⁷',
  '48a⁵b⁷',
  '48a⁴b⁵',
  '12a⁴b⁵',
  'B',
  'Primero (4ab²)² = 16a²b⁴. Luego 3a³b³ · 16a²b⁴ = 48 · a^(3+2) · b^(3+4) = 48a⁵b⁷.',
  14
),

-- ── Ejercicio 3: Desarrolla y simplifica ─────────────────────

(
  '[Álgebra 3a] Desarrolla y simplifica 3(x+6) + 4(2x−5).',
  '11x − 2',
  '11x + 2',
  '5x − 2',
  '11x + 38',
  'A',
  '3(x+6) = 3x+18 y 4(2x−5) = 8x−20. Sumando: (3x+8x) + (18−20) = 11x − 2.',
  16
),

(
  '[Álgebra 3b] Desarrolla (x+3)(4x−5).',
  '4x² + 7x − 15',
  '4x² − 7x − 15',
  '4x² + 17x − 15',
  '4x² + 7x + 15',
  'A',
  '(x+3)(4x−5) = x·4x − x·5 + 3·4x − 3·5 = 4x² − 5x + 12x − 15 = 4x² + 7x − 15.',
  17
),

(
  '[Álgebra 3d] Desarrolla (2x+3)².',
  '4x² + 9',
  '4x² + 6x + 9',
  '4x² + 12x + 9',
  '2x² + 12x + 9',
  'C',
  '(2x+3)² = (2x)² + 2·(2x)·3 + 3² = 4x² + 12x + 9. Recordá el trinomio cuadrado perfecto: (a+b)² = a² + 2ab + b².',
  19
),

(
  '[Álgebra 3e] Desarrolla (x+2)³.',
  'x³ + 8',
  'x³ + 6x² + 12x + 8',
  'x³ + 3x² + 6x + 8',
  'x³ + 6x + 8',
  'B',
  '(x+2)³ = x³ + 3·x²·2 + 3·x·4 + 8 = x³ + 6x² + 12x + 8. Se usa (a+b)³ = a³ + 3a²b + 3ab² + b³.',
  20
);

-- ============================================================
-- PREGUNTAS DE ANÁLISIS MATEMÁTICO I (primera clase)
-- ============================================================

INSERT INTO preguntas (enunciado, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, orden) VALUES

(
  '¿Cuál es la pendiente de la función lineal f(x) = 3x + 5?',
  '5',
  '3',
  'x',
  '8',
  'B',
  'En una función lineal f(x) = mx + b, m es la pendiente y b es la ordenada al origen. Aquí m = 3 y b = 5, por lo tanto la pendiente es 3.',
  31
),

(
  '¿Cuál es la ordenada al origen de f(x) = 2x − 4?',
  '2',
  '−2',
  '−4',
  '4',
  'C',
  'La ordenada al origen es el valor de f cuando x = 0: f(0) = 2·0 − 4 = −4. En f(x) = mx + b, el término b es siempre la ordenada al origen.',
  32
),

(
  'Si f(x) = −x + 7, ¿cuál es el valor de f(3)?',
  '4',
  '−4',
  '10',
  '−10',
  'A',
  'Se reemplaza x = 3 en la función: f(3) = −3 + 7 = 4. Para evaluar una función en un punto, simplemente se sustituye el valor de x en la expresión.',
  33
),

(
  'La derivada de f(x) = x³ usando la definición es:',
  '3x',
  '3x²',
  'x²',
  'x⁴/4',
  'B',
  'Aplicando la regla de potencias d/dx(xⁿ) = n·xⁿ⁻¹: d/dx(x³) = 3·x² . También se puede verificar desde la definición f''(x) = lím(h→0) [(x+h)³−x³]/h expandiendo el binomio.',
  34
),

(
  'Un número real r es racional si:',
  'Es la raíz cuadrada de un entero',
  'Puede escribirse como p/q con p,q ∈ ℤ y q ≠ 0',
  'Tiene infinitos decimales',
  'No puede ser expresado como fracción',
  'B',
  'Los racionales son exactamente los números que se pueden expresar como cociente de dos enteros con denominador no nulo. Los irracionales (como √2 o π) tienen decimales infinitos no periódicos y NO pueden expresarse como p/q.',
  39
);
