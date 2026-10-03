# Imagen de ejecucion, no de construccion: aqui no se compila ni se instala
# nada. El artefacto (src/, public/, manifiestos y node_modules de produccion)
# ya viene construido y probado desde el job de integracion continua.
#
# Es el equivalente de SCM_DO_BUILD_DURING_DEPLOYMENT=false en App Service:
# se despliega el artefacto, no el codigo fuente.
FROM node:22-slim

USER node
WORKDIR /app

COPY --chown=node:node . /app

ENV NODE_ENV=production
EXPOSE 8080

CMD ["node", "src/server.js"]
