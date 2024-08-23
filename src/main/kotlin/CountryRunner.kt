package com.jetbrains
import com.jetbrains.common.FileReader

/**
 * The constant that represents the separator used between columns in a [resources/countries.csv] file.
 */
private const val CSV_COLUMN_SEPARATOR: String = ","

fun parseCountries(countriesCSVLines: List<String>): List<Country> {
    TODO("Parse countries.csv file lines and map it to list of countries (List<Country>)")
}

fun newCountryPortal(countries: List<Country>): CountryApi {
    TODO("Instantiate and return instance of CountryPortal class.")
}

fun main() {
    val countryCSVLines = FileReader.readFileInResources("countries.csv")
    val countries = parseCountries(countryCSVLines)
    val countriesApi = newCountryPortal(countries)

    print(countriesApi.getTopNCountriesWithTheHighestLifeExpectancy(5))
}
