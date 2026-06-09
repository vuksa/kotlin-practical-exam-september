## Country Information Portal
This assignment asks students to model country data, parse a CSV file, and implement a small query API over that data.

### Setup
- Use the Gradle wrapper that is committed to this repository.
- The project is pinned to Gradle `9.5.1` and Kotlin `2.4.0`.
- The build targets Java `21`.
- If students work inside IntelliJ IDEA, the bundled JetBrains Runtime is enough to import the project and run Gradle tasks. No separate Gradle install is required.
- For terminal use on macOS and Linux, run `sh ./run-gradle.cmd ...`.
- For terminal use on Windows, run `.\run-gradle.cmd ...`.
- The single `run-gradle.cmd` bootstrap reuses JDK `21` from `JAVA_HOME`, `PATH`, `~/.jdks`, `%USERPROFILE%\\.jdks`, or common system locations, and downloads the correct Amazon Corretto `21` archive for the current OS if needed.
- Verify the environment with one of:

```shell
sh ./run-gradle.cmd compileKotlin
```

```powershell
.\run-gradle.cmd compileKotlin
```

- The starter project intentionally contains placeholders and incomplete types, so `run-gradle ... test` is expected to fail until the assignment is implemented.

### Contents
- `CountryApi.kt`
- `CountryRunner.kt`
- `models.kt`

The following types are part of the assignment:
- `President`: represents a president.
- `Country`: represents a country with its related data.
- `Continent`: enum class for continents.
- `CountryApi`: interface defining the required queries.

### Tasks
#### Task 1: Create Entity Classes
###### Total points: 10
In `models.kt`, create the following entities:
- `President`: data class with the primary constructor property `name: String`.
- `Country`: data class with the primary constructor properties:
  - `name: String`
  - `continent: Continent`
  - `governmentForm: String`
  - `lifeExpectancy: Double`
  - `president: President`
- `Continent`: enum class containing the required continent names (for example, `ASIA`, `EUROPE`, and so on).

#### Task 2: Parse the input CSV file `countries.csv`
###### Total points: 10
Implement the top-level `parseCountries` function in `CountryRunner.kt` so it parses [countries.csv](src/main/resources/countries.csv) and returns `List<Country>`.

Columns in the CSV file are separated by a comma character (`,`).

#### Task 3: Create `CountryPortal` and implement the `CountryApi` interface
###### Total points: 40

##### Note
Prefer Kotlin collection APIs such as `map`, `filter`, `flatMap`, `distinct`, `groupingBy`, `maxByOrNull`, and `find`.
Imperative solutions using loops are acceptable, but each such task receives a `2` point deduction.

#### Task 3.1
###### Points: 4
Create a `CountryPortal` class in the same package as `CountryRunner.kt` and `models.kt`.
`CountryPortal` should have a primary constructor with a `countries: List<Country>` property and should implement `CountryApi`.

#### Task 3.2: Implement `CountryPortal.getTopNCountriesWithTheHighestLifeExpectancy`
###### Points: 4
Return the top `N` countries with the highest life expectancy.

Verify Task 3.2 with:
```shell
./gradlew test --tests "CountryPortalTest.test - get top N countries with the highest life expectancy"
```

#### Task 3.3: Implement `CountryPortal.getAllPresidents`
###### Points: 8
Return a list of all presidents without duplicates.

Verify Task 3.3 with:
```shell
./gradlew test --tests "CountryPortalTest.test - get all presidents"
```

#### Task 3.4: Implement `CountryPortal.getCountriesByGovernmentFormAndContinent`
###### Points: 8
Return all countries with the provided government form and continent.

Verify Task 3.4 with:
```shell
./gradlew test --tests "CountryPortalTest.test - get all countries by government form and continent"
```

#### Task 3.5: Implement `CountryPortal.getCountriesWithMostCommonGovernmentForm`
###### Points: 8
Return all countries with the most common government form, sorted by name in descending order.

Verify Task 3.5 with:
```shell
./gradlew test --tests "CountryPortalTest.test - get all countries with the most common government form"
```

#### Task 3.6: Implement `CountryPortal.findMostCommonPresident`
###### Points: 8
Return the `President` who is the leader of the most countries.

Verify Task 3.6 with:
```shell
./gradlew test --tests "CountryPortalTest.test - find most common president"
```
