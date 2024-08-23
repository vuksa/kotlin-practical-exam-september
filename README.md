## Country Information Portal
This project provides a portal to access various information about countries, including life expectancy, government forms, and presidents.

### Contents
- `CountryApi.kt`
- `CountryRunner.kt`
- `models.kt`

In `CountryApi.kt` and `models.kt`, the following classes and interfaces are defined:
- `President`: Represents a president. 
- `Country`: Represents a country with various properties. 
- `Continent`: Enum class for different continents. 
- `CountryApi`: Interface defining methods to retrieve information about countries.

### Tasks
#### Task 1: Create Entity Classes
###### Total points: 10
In models.kt, create the following entities:
- `President`: Data class with the primary constructor property:
    - `name` (`String`) - Name of the president.
- `Country`: Data class with the primary constructor properties:
  - `name` (`String`) - Name of the country.
  - `continent` (`Continent`) - Continent to which the country belongs.
  - `governmentForm` (`String`) - Form of government.
  - `lifeExpectancy` (`Double`) - Life expectancy in the country.
  - `presidents` (`List<President>`) - List of presidents the country has had.
- `Continent`: Enum class representing different continents (e.g., ASIA, EUROPE, etc.).

#### Task 2: Parse the entry CSV file countries.csv
###### Total points: 10
Implement the `CountryRunner.parseCountries` function to parse the entry CSV file [countries.csv](src/main/resources/countries.csv). As a result, 
`CountryRunner.parseCountries` function should return the list of countries List<Countries> listed in CSV file with their 
corresponding properties.

Columns in the CSV file are split by a comma character (,).

#### Task 3: Create class `CountryPortal` and implement functions of `CountryApi` interface.
###### Total points: 40

##### ***Note***:
Leverage Kotlin APIs on Collections such as `map`, `filter`,
`flatmap`, `distinct`, `groupingBy`, `maxByOrNull`, `find`, etc. and functional approach to implement your solution.
Implementing the solutions in an imperative way by not using these APIs(for example, using for loops) will be accepted,
but it **will result in 2 points deduction penalty** per task.

#### Task 3.1
###### Points: 4
Create a class `CountryPortal` in the same package where `CountryRunner.kt` and `models.kt` files are defined.
`CountryPortal` should have a primary constructor with a `countries: List<Country>` class property.
Class `CountryPortal` should implement `CountryApi` interface.

#### Task 3.2 Implement `CountryPortal.getTopNCountriesWithTheHighestLifeExpectancy` function
###### Points: 4
`CountryPortal.getTopNCountriesWithTheHighestLifeExpectancy` function should return return top N
countries with the highest life expectancy.

#### Verify Task 3.2 implementation by running bellow task.
```shell
./gradlew :test --tests "CountryPortalTest.test - get top N countries with the highest life expectancy"
```

#### Task 3.3 Implement `CountryPortal.getAllPresidents` function
###### Points: 8
`CountryPortal.getAllPresidents` function should return a list of all presidents. Make sure that result list needs to
contain each name only once. No duplicates should be present.

#### Verify Task 3.3 implementation by running bellow task.
```shell
./gradlew :test --tests "CountryPortalTest.test - get all presidents"
```

#### Task 3.4 Implement `CountryPortal.getCountriesByGovernmentFormAndContinent` function
###### Points: 8
`CountryPortal.getCountriesByGovernmentFormAndContinent` function should return a list of all countries with a 
provided government form and continent. 

#### Verify Task 3.4 implementation by running bellow task.
```shell
./gradlew :test --tests "CountryPortalTest.test - get all countries by government form and continent"
```

#### Task 3.5 Implement `CountryPortal.getCountriesWithMostCommonGovernmentForm` function
###### Points: 8
`CountryPortal.getCountriesWithMostCommonGovernmentForm` function should return a list of all countries with a 
most common government form.

#### Verify Task 3.5 implementation by running bellow task.
```shell
./gradlew :test --tests "CountryPortalTest.test - get all countries with the most common government form"
```

#### Task 3.6 Implement `CountryPortal.findMostCommonPresident` function
###### Points: 8
`CountryPortal.findMostCommonPresident` function should return the name of the president who is the leader of the most 
countries.

#### Verify Task 3.6 implementation by running bellow task.
```shell
./gradlew :test --tests "CountryPortalTest.test - find most common president"
```
