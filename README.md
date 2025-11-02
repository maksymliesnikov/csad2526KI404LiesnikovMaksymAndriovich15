# csad2526KI404LiesnikovMaksymAndriovich15

Команда для білду проекту: 
```
cmake -S . -B build
cmake --build build
```

Як збирати і запускати юніт-тести (Google Test)

- CMake використовує FetchContent, щоб автоматично завантажити Google Test при конфігурації. Потрібен доступ до інтернету при першій конфігурації.

- Щоб зібрати тільки тестовий виконуваний файл і прогнати тести вручну:

```
# Конфігуруємо проект (скачується googletest під час цієї кроку)
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

# Збираємо ціль unit_tests
cmake --build build --config Release --target unit_tests -j 4

# Запускаємо тестовий виконуваний файл напряму
./build/bin/unit_tests
```

- Альтернативно, якщо у вас доступна утиліта `ctest` (з комплекту CMake), можна запустити тести через CTest:

```
ctest --test-dir build --output-on-failure
```

Поради та усунення несправностей
- Якщо під час конфігурації CMake не може знайти інтернет або завантаження fails, спробуйте повторити команду пізніше або додати googletest як підмодуль у репозиторій.
- Якщо `ctest` не знайдено в PATH, запускайте бінарний файл тестів безпосередньо (`./build/bin/unit_tests`).
