# DemoDay Script — Skills & Agent Claude Code
## 10 minutos | Sin slides | El código habla

---

## Acto 1 — Intro (1.5 min)

### Comandos en terminal:
```bash
ls -la                              # repo casi vacío
cat CLAUDE.md                       # estándares que el agente va a seguir
cat docs/WORKFLOW.md                # diagrama del flujo
ls .claude/skills/                  # skills disponibles
```

### Lo que dices:
> "El equipo usa Cursor — funciona, es pair programming asistido.
> Yo uso Claude Code. La diferencia no es el modelo,
> es el paradigma: un agente autónomo que trabaja mientras tú lo observas.
> Este repo tiene un skeleton vacío. Voy a escribir un solo comando
> y dos agentes van a construir el backend y el frontend en paralelo,
> en ramas separadas, sin que yo escriba una línea de código."

### Muestra el skeleton:
```bash
cat demo/backend/main.py            # solo stubs vacíos
cat demo/frontend/src/App.jsx       # solo estructura vacía
cat .claude/skills/demo-build/SKILL.md | head -25
```

> "Este es un skill — un prompt especializado que convierte a Claude Code
> en un orquestador. Al invocarlo, crea dos worktrees y despacha
> dos subagentes simultáneamente usando el Task tool."

---

## Acto 2 — Demo en vivo (6.5 min)

### El único comando que escribes:
```
/demo-build
```

### Lo que narras mientras los agentes trabajan:

**Cuando crea los worktrees:**
> "Está creando dos directorios de trabajo aislados.
> Git worktrees: mismo repositorio, dos branches — feature/backend y
> feature/frontend — sin interferirse. Es como tener dos desarrolladores
> trabajando en el mismo repo al mismo tiempo."

**Cuando despacha los subagentes en paralelo:**
> "Aquí está el momento clave. Está lanzando los dos agentes
> en el mismo mensaje usando el Task tool.
> El backend agent va a implementar FastAPI con 4 endpoints y 5 tests.
> El frontend agent va a construir el React UI con CRUD completo.
> Simultáneamente. Yo no escribo nada."

**Mientras trabajan (pausa natural, ~4 minutos):**
> "Esto es lo que diferencia un agente de un autocomplete.
> El agente tiene contexto completo del proyecto: lee el CLAUDE.md,
> entiende los estándares, planifica los archivos, escribe los tests,
> implementa, verifica, commitea. Todo de forma autónoma.
> Y lo está haciendo en dos ramas al mismo tiempo."

**Cuando terminan:**
```bash
git log --oneline --all --graph     # muestra commits en ambas ramas
```
> "Dos ramas, dos commits, cero intervención manual."

---

## Acto 3 — Code Review en vivo (2 min)

### Lo que dices antes de invocar:
> "Ahora la parte que uso en producción —
> el agente de code review. Va a tomar el backend,
> correr el formatter, el linter, los tests,
> y si encuentra algo que no cumple los estándares
> del CLAUDE.md lo corrige solo — con el Edit tool,
> leyendo el código antes de tocarlo."

### El comando:
```
/code-review
```

### Lo que narras:
> "Está corriendo ruff format, ruff check, pytest.
> Si hay algo fuera de estándar lo va a corregir
> y commitear. Mismo skill que uso en producción."

---

## Acto 4 — La app corre (30 seg)

```bash
./run.sh
# Browser: http://localhost:5173
```

> "Una Todo App funcional — backend FastAPI, frontend React,
> construida por agentes, revisada por un agente,
> corriendo en local. Todo desde un solo skill."

---

## Acto 5 — Cierre (30 seg)

> "Dos agentes en paralelo, branches aisladas, code review automatizado,
> estándares definidos en CLAUDE.md que viajan con el repo.
> El workflow completo: brainstorming → plan → execute → code-review.
> La pregunta no es si usar IA — es qué nivel de autonomía le das."

---

## Fallback si algo falla

**Si /demo-build se traba:**
- Muestra `docs/WORKFLOW.md` — el diagrama explica el concepto
- Muestra `.claude/skills/demo-build/SKILL.md` — el skill es el código

**Si un subagente falla:**
- El otro sigue — ese es el punto de los worktrees independientes
- Di: "El fallo en una rama no afecta la otra — aislamiento real."

**Si /code-review no encuentra nada:**
- Es el mejor escenario — el subagente ya siguió los estándares
- Di: "Salió limpio — el agente de backend leyó el CLAUDE.md
  y escribió código que ya cumple los estándares."
