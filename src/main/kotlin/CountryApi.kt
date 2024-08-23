package com.jetbrains

/*
*   Interface defining task that should be implemented.
*/
interface CountryApi {

    /**
     * Retrieves the top N countries with the highest life expectancy.
     *
     * @param n The number of countries to retrieve.
     *
     * @return A list of Country objects representing the top N countries with the highest life expectancy.
     */
    fun getTopNCountriesWithTheHighestLifeExpectancy(n: Int): List<Country>

    /**
     * Retrieves a list of all presidents.
     *
     * @return A list of [President] objects representing all the presidents.
     */
    fun getAllPresidents(): List<President>

    /**
     * Retrieves a collection of countries that match the given government form and continent.
     *
     * @param governmentForm The government form to filter countries by.
     * @param continent The continent to filter countries by.
     * @return A list of [Country] objects representing the countries that match the given government form and continent.
     */
    fun getCountriesByGovernmentFormAndContinent(governmentForm: String, continent: Continent): List<Country>

    /**
     * Retrieves a list of countries with the most common government form.
     *
     * @return A list of [Country] objects representing the countries with the most common government form.
     */
    fun getCountriesWithMostCommonGovernmentForm(): List<Country>

    /**
     * Retrieves the most common president.
     *
     * @return The most common [President] object representing the most common president.
     */
    fun findMostCommonPresident(): President

}