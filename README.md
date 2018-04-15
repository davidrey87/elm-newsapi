# News API - ELM

Programa de ELM que consume el API de https://newsapi.org/

## Empezar
Instalar Elm:

https://guide.elm-lang.org/install.html

Clonar el repositorio:

```bash
git clone https://github.com/davidrey87/elm-newsapi.git
cd elm-newsapi
```
Correr programa:

```bash
elm-live Main.elm --open --output=elm.js
```

## Obtener Key

Para este proyecto utilizamos el API de noticias [Newsapi](https://newsapi.org/v2/), en el cual requerimos una llave para poder consumirla. Esta API nos da la oportunidad de obtener una llave como desarrollador, en la cual nos ofrecen 1000 solicitudes diarias. Para poder conseguir nuestra llave debemos:

1. Registranos en https://newsapi.org/register y validar nuestro correo electrónico.
2. Recibiremos un correo electrónico con una llave (key) que se nos ha asignado.
3. Colocar esta llave en `Use.elm`:

#### Use.elm

```elm

module Use exposing (key)

key : String
key =
    "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

```

**Note:** Por seguridad, no olvides agregar Use.elm a .gitignore.