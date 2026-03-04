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
VALUES ('Facundo', '33210626', 'facundo@pymetech.com.ar', 'admin')
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
  '[Álgebra 2a] ¿Cuánto vale √200 − √32?',
  '√168',
  '4√2',
  '6√2',
  '14√2',
  'C',
  '√200 = √(100·2) = 10√2; √32 = √(16·2) = 4√2. Entonces 10√2 − 4√2 = 6√2.',
  13
),

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

(
  '[Álgebra 2c] Simplifica (3x^(3/2)y³ / (x²y^(-1/2)))^(-2).',
  'x/(9y⁷)',
  '9x/y⁷',
  'x²/(9y⁷)',
  '9y⁷/x',
  'A',
  'Dentro del paréntesis: 3·x^(3/2-2)·y^(3+1/2) = 3x^(-1/2)y^(7/2). Elevando a -2: 3^(-2)·x^1·y^(-7) = x/(9y⁷).',
  15
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
  '[Álgebra 3c] Desarrolla (√a + √b)(√a − √b).',
  'a + b',
  'a − b',
  '(√a)² − (√b)²',
  'Tanto B como C son correctas',
  'D',
  'Es una diferencia de cuadrados: (√a+√b)(√a−√b) = (√a)² − (√b)² = a − b. Las opciones B y C son expresiones equivalentes, por lo que ambas son correctas.',
  18
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
),

-- ── Ejercicio 4: Factoriza ────────────────────────────────────

(
  '[Álgebra 4a] Factoriza 4x² − 25.',
  '(2x − 5)²',
  '(4x − 5)(x + 5)',
  '(2x + 5)(2x − 5)',
  '(2x − 5)(2x + 25)',
  'C',
  '4x²−25 = (2x)²−5². Es una diferencia de cuadrados perfectos: a²−b² = (a+b)(a−b), con a=2x y b=5.',
  21
),

(
  '[Álgebra 4b] Factoriza 2x² + 5x − 12.',
  '(2x − 3)(x + 4)',
  '(2x + 3)(x − 4)',
  '(x + 3)(2x − 4)',
  '(2x − 4)(x + 3)',
  'A',
  'Buscamos dos factores (2x + m)(x + n) donde m·n = −12 y 2n+m = 5. Probando m=−3, n=4: (2x−3)(x+4) = 2x²+8x−3x−12 = 2x²+5x−12 ✓.',
  22
),

(
  '[Álgebra 4c] Factoriza x³ − 3x² − 4x + 12.',
  '(x − 3)(x − 2)(x + 2)',
  '(x + 3)(x² − 4)',
  '(x² − 4)(x + 3)',
  '(x − 2)(x² + 2)',
  'A',
  'Agrupando: x²(x−3) − 4(x−3) = (x²−4)(x−3) = (x−2)(x+2)(x−3). Los tres factores lineales son (x−2), (x+2) y (x−3).',
  23
),

(
  '[Álgebra 4d] Factoriza x⁴ + 27x.',
  'x(x³ + 27)',
  'x(x + 3)(x² − 3x + 9)',
  'x(x + 3)²(x − 3)',
  'Tanto A como B son formas válidas',
  'D',
  'x⁴+27x = x(x³+27). Como x³+27 es suma de cubos: x(x+3)(x²−3x+9). Tanto A (sin terminar) como B (completamente factorizado) son formas válidas; B es la forma más reducida.',
  24
),

(
  '[Álgebra 4e] Factoriza 3x^(3/2) − 9x^(1/2) + 6x^(-1/2).',
  '3x^(-1/2)(x² − 3x + 2)',
  '3x^(-1/2)(x − 1)(x − 2)',
  '3(x − 1)(x − 2) / √x',
  'Todas las anteriores son equivalentes',
  'D',
  'Factor común 3x^(-1/2): 3x^(-1/2)(x²−3x+2) = 3x^(-1/2)(x−1)(x−2) = 3(x−1)(x−2)/√x. Las tres formas son equivalentes.',
  25
),

(
  '[Álgebra 4f] Factoriza x³y − 4xy.',
  'xy(x² − 4)',
  'xy(x + 2)(x − 2)',
  'x(x²y − 4y)',
  'Tanto A como B son correctas',
  'D',
  'xy(x²−4) es el factoreo con monomio común. Como x²−4 es diferencia de cuadrados, la forma completamente factorizada es xy(x+2)(x−2). A y B son ambas correctas (A es el paso intermedio).',
  26
),

-- ── Ejercicio 5: Simplifica expresiones racionales ───────────

(
  '[Álgebra 5a] Simplifica (x² + 3x + 2) / (x² − x − 2).',
  '(x + 1)/(x − 1)',
  '(x + 2)/(x − 2)',
  '(x + 2)/(x + 1)',
  '3x/(−x)',
  'B',
  'Numerador: (x+1)(x+2). Denominador: (x+1)(x−2). Cancelando (x+1) (con x ≠ −1): resultado = (x+2)/(x−2).',
  27
),

(
  '[Álgebra 5b] Simplifica [(2x²−x−1)/(x²−9)] · [(x+3)/(2x+1)].',
  '(x−1)/(x−3)',
  '(x+1)/(x+3)',
  '(2x+1)/(x−3)',
  '(x−1)/(x+3)',
  'A',
  'Factorizando: (2x+1)(x−1)/[(x+3)(x−3)] · (x+3)/(2x+1). Se cancelan (2x+1) y (x+3), quedando (x−1)/(x−3).',
  28
),

(
  '[Álgebra 5c] Simplifica x²/(x²−4) − (x+1)/(x+2).',
  '(x+2)/(x−2)',
  '1/(x−2)',
  '(x−1)/(x−2)',
  '(x+1)/(x−2)',
  'B',
  'MCD = (x+2)(x−2). Reescribiendo: x²/[(x+2)(x−2)] − (x+1)(x−2)/[(x+2)(x−2)] = [x²−(x²−x−2)] / [(x+2)(x−2)] = (x+2)/[(x+2)(x−2)] = 1/(x−2).',
  29
),

(
  '[Álgebra 5d] Simplifica (y/x − x/y) / (1/y − 1/x).',
  'x + y',
  '−(x + y)',
  '(x + y)/(x − y)',
  '1',
  'B',
  'Numerador: (y²−x²)/(xy). Denominador: (x−y)/(xy). Dividiendo: (y²−x²)/(x−y) = (y+x)(y−x)/(x−y) = −(x+y)(x−y)/(x−y) = −(x+y).',
  30
);

-- ============================================================
-- PREGUNTAS DE ANÁLISIS MATEMÁTICO I (primera clase)
-- ============================================================

INSERT INTO preguntas (enunciado, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, orden) VALUES

(
  '¿Cuál es el valor de lím(x→1) (x² − 1) / (x − 1)?',
  '0',
  '1',
  '2',
  'No existe',
  'C',
  'Factorizando: (x²−1)/(x−1) = (x+1)(x−1)/(x−1) = x+1. Evaluando en x=1 obtenemos 1+1 = 2.',
  31
),

(
  'Una función f es continua en x = a si y solo si:',
  'f(a) está definida',
  'lím(x→a) f(x) existe',
  'lím(x→a) f(x) = f(a) y ambos existen',
  'f es derivable en a',
  'C',
  'La definición de continuidad exige tres condiciones simultáneas: f(a) definida, el límite existe y ambos son iguales. La derivabilidad es una condición más fuerte (implica continuidad, pero no al revés).',
  32
),

(
  '¿Cuánto vale lím(x→0) sen(x) / x?',
  '0',
  '∞',
  'No existe',
  '1',
  'D',
  'Este es el límite trigonométrico fundamental. Geométricamente se puede demostrar con el teorema del emparedado (Sandwich). El resultado es 1 y es clave en el cálculo de derivadas trigonométricas.',
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
  '¿Cuál de los siguientes conjuntos es un ejemplo de conjunto abierto en ℝ?',
  '[0, 1]',
  '[0, 1)',
  '(0, 1)',
  '{0, 1}',
  'C',
  'Un conjunto abierto en ℝ no contiene sus puntos frontera. El intervalo (0,1) excluye tanto el 0 como el 1, por lo que todos sus puntos son interiores. [0,1] es cerrado, [0,1) es semiabierto, y {0,1} es un conjunto finito (cerrado).',
  35
),

(
  'Si f(x) = eˣ, ¿cuál es su derivada f''(x)?',
  'xeˣ⁻¹',
  'eˣ · x',
  'eˣ',
  '0',
  'C',
  'La función exponencial natural eˣ es su propia derivada: d/dx(eˣ) = eˣ. Esta propiedad única la convierte en una función fundamental del análisis matemático.',
  36
),

(
  '¿Qué expresa el Teorema del Valor Medio de Lagrange?',
  'Toda función continua alcanza su máximo y mínimo en un intervalo cerrado',
  'Si f es continua en [a,b] y derivable en (a,b), existe c ∈ (a,b) tal que f''(c) = [f(b)−f(a)]/(b−a)',
  'Si f(a) y f(b) tienen signos opuestos, existe c ∈ (a,b) tal que f(c) = 0',
  'La derivada de una función constante es cero',
  'B',
  'El TVM de Lagrange garantiza la existencia de al menos un punto c donde la pendiente de la tangente iguala a la pendiente de la secante entre a y b. La opción C describe el Teorema de Bolzano (caso particular del TVI).',
  37
),

(
  'La regla de la cadena para (f ∘ g)''(x) es:',
  'f''(x) + g''(x)',
  'f''(x) · g''(x)',
  'f''(g(x)) · g''(x)',
  'f(g''(x))',
  'C',
  'La regla de la cadena establece que la derivada de una función compuesta es: derivada de la función exterior evaluada en la interior, multiplicada por la derivada de la función interior. Ejemplo: d/dx[sen(x²)] = cos(x²)·2x.',
  38
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
),

(
  '¿Cuál es el límite lím(x→∞) (3x² + 2x) / (x² − 5)?',
  '0',
  '3',
  '∞',
  '2',
  'B',
  'Para límites al infinito de funciones racionales, se divide numerador y denominador por la mayor potencia de x (aquí x²): (3 + 2/x) / (1 − 5/x²). Cuando x→∞, los términos con x en denominador tienden a 0, quedando 3/1 = 3.',
  40
);
