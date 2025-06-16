# Этап сборки
FROM dart:stable AS build

WORKDIR /app

# Копируем pubspec и загружаем зависимости
COPY pubspec.* ./
RUN dart pub get

# Копируем весь проект
COPY . .

# Компилируем сервер в исполняемый файл
RUN dart compile exe app/server.dart -o bin/server

# Финальный минимальный образ
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
CMD ["/app/bin/server"]
