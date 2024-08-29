import com.jetbrains.Continent
import com.jetbrains.common.FileReader
import com.jetbrains.newCountryPortal
import com.jetbrains.parseCountries
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class CountryPortalTest {
    private val countries = parseCountries(FileReader.readFileInResources("countries.csv"))
    private val countryPortalApi = newCountryPortal(countries)

    @Test
    fun `test - get top N countries with the highest life expectancy`() {
        val actualSortedCountries = countryPortalApi.getTopNCountriesWithTheHighestLifeExpectancy(5)
            .map { it.name }
            .sorted()
        val expectedCountries = listOf("Japan", "Macao", "Singapore", "Sweden", "Switzerland")

        assertEquals(
            expectedCountries,
            actualSortedCountries,
            "Expected countries are $expectedCountries, but found $actualSortedCountries instead."
        )
    }

    @Test
    fun `test - get all presidents`() {
        val actualPresidents = countryPortalApi.getAllPresidents()
            .distinct()
            .sortedBy { it.name }
            .map { it.name }
        val expectedPresidents = EXPECTED_PRESIDENTS

        assertEquals(
            expectedPresidents,
            actualPresidents,
            "Expected presidents are $expectedPresidents, but found $actualPresidents instead."
        )
    }

    @Test
    fun `test - get all countries by government form and continent`() {
        val actualCountries = countryPortalApi.getCountriesByGovernmentFormAndContinent("Republic", Continent.EUROPE)
            .sortedBy { it.name }.map { it.name }

        val expectedCountries = REPUBLICS_IN_EUROPE

        assertEquals(
            expectedCountries,
            actualCountries,
            "Expected countries are $expectedCountries, but found $actualCountries instead."
        )
    }

    @Test
    fun `test - get all countries with the most common government form`() {
        val actualCountries = countryPortalApi.getCountriesWithMostCommonGovernmentForm()
            .sortedBy { it.name }
            .map { it.name }

        val expectedCountries = ALL_REPUBLIC_COUNTRIES

        assertEquals(
            expectedCountries,
            actualCountries,
            "Expected countries are $expectedCountries, but found $actualCountries instead."
        )
    }

    @Test
    fun `test - find most common president`() {
        assertEquals("Elisabeth II", countryPortalApi.findMostCommonPresident().name)
    }

    companion object {
        private val EXPECTED_PRESIDENTS = listOf(
            "Abdiqassim Salad Hassan",
            "Abdoulaye Wade",
            "Abdullah II",
            "Adolf Ogi",
            "Ahmed Tejan Kabbah",
            "Ahmet Necdet Sezer",
            "Akihito",
            "Aleksander Kwasniewski",
            "Alfonso Portillo Cabrera",
            "Ali Abdallah Salih",
            "Ante Jelavic",
            "António Mascarenhas Monteiro",
            "Arnoldo Alemán Lacayo",
            "Arthur N. R. Robinson",
            "Askar Akajev",
            "Azali Assoumani",
            "Bakili Muluzi",
            "Bashar al-Assad",
            "Beatrix",
            "Benjamin William Mkapa",
            "Bernard Dowiyogo",
            "Bharrat Jagdeo",
            "Bhumibol Adulyadej",
            "Boris Trajkovski",
            "Carl XVI Gustaf",
            "Carlo Azeglio Ciampi",
            "Carlos Roberto Flores Facussé",
            "Cassam Uteem",
            "Chandrika Kumaratunga",
            "Charles Taylor",
            "Chen Shui-bian",
            "Daniel arap Moi",
            "Denis Sassou-Nguesso",
            "Didier Ratsiraka",
            "Elisabeth II",
            "Emomali Rahmonov",
            "Ferenc Mádl",
            "Festus G. Mogae",
            "Fidel Castro Ruz",
            "France-Albert René",
            "Francisco Guillermo Flores Pérez",
            "Frederick Chiluba",
            "George W. Bush",
            "Glafkos Klerides",
            "Gloria Macapagal-Arroyo",
            "Gnassingbé Eyadéma",
            "Guido de Marco",
            "Gustavo Noboa Bejarano",
            "Gyanendra Bir Bikram",
            "Hamad ibn Isa al-Khalifa",
            "Hamad ibn Khalifa al-Thani",
            "Hans-Adam II",
            "Harald V",
            "Henri",
            "Heydär Äliyev",
            "Hipólito Mejía Domínguez",
            "Hugo Chávez Frías",
            "Ion Iliescu",
            "Isayas Afewerki [Isaias Afwerki]",
            "Islam Karimov",
            "Ismail Omar Guelleh",
            "Jabir al-Ahmad al-Jabir al-Sabah",
            "Jacques Chirac",
            "Jean-Bertrand Aristide",
            "Jiang Zemin",
            "Jigme Singye Wangchuk",
            "Joaquím A. Chissano",
            "Johannes Rau",
            "John Bani",
            "John Kufuor",
            "Jorge Batlle Ibáñez",
            "Jorge Sampãio",
            "Josefa Iloilo",
            "José Alexandre Gusmão",
            "Juan Carlos I",
            "Kessai Note",
            "Khamtay Siphandone",
            "Kim Dae-jung",
            "Kim Jong-il",
            "Kostis Stefanopoulos",
            "Kumba Ialá",
            "Kuniwo Nakamura",
            "Lansana Conté",
            "Lennart Meri",
            "Letsie III",
            "Luis Ángel González Macchi",
            "Malietoa Tanumafili II",
            "Margrethe II",
            "Mary McAleese",
            "Mathieu Kérékou",
            "Maumoon Abdul Gayoom",
            "Miguel Trovoada",
            "Miguel Ángel Rodríguez Echeverría",
            "Milan Kucan",
            "Mireya Elisa Moscoso Rodríguez",
            "Mohammad Omar",
            "Mohammad Rafiq Tarar",
            "Mohammed Abdel Aziz",
            "Mohammed VI",
            "Moshe Katzav",
            "Mswati III",
            "Norodom Sihanouk",
            "Olusegun Obasanjo",
            "Omar Bongo",
            "Paul Biya",
            "Paul Kagame",
            "Petar Stojanov",
            "Pierre Buyoya",
            "Qabus ibn Sa´id",
            "Rainier III",
            "Rexhep Mejdani",
            "Ricardo Lagos Escobar",
            "Robert G. Mugabe",
            "Ronald Venetiaan",
            "Rudolf Schuster",
            "Saddam Hussein al-Takriti",
            "Sam Nujoma",
            "Saparmurad Nijazov",
            "Sellapan Rama Nathan",
            "Shahabuddin Ahmad",
            "Tarja Halonen",
            "Taufa'ahau Tupou IV",
            "Teburoro Tito",
            "Teodoro Obiang Nguema Mbasogo",
            "Thomas Klestil",
            "Trân Duc Luong",
            "Vaira Vike-Freiberga",
            "Valdas Adamkus",
            "Vernon Shaw",
            "Vladimir Voronin",
            "Václav Havel",
            "Yahya Jammeh",
            "Yasser (Yasir) Arafat",
            "Yoweri Museveni",
            "Zayid bin Sultan al-Nahayan",
            "Zine al-Abidine Ben Ali",
            "kenraali Than Shwe",
            "Émile Lahoud",
            "Ólafur Ragnar Grímsson"
        )

        val REPUBLICS_IN_EUROPE = listOf(
            "Albania",
            "Bulgaria",
            "Czech Republic",
            "Estonia",
            "Finland",
            "France",
            "Greece",
            "Hungary",
            "Iceland",
            "Ireland",
            "Italy",
            "Latvia",
            "Lithuania",
            "Macedonia",
            "Malta",
            "Moldova",
            "Poland",
            "Portugal",
            "Romania",
            "Slovakia",
            "Slovenia"
        )

        val ALL_REPUBLIC_COUNTRIES = listOf(
            "Albania",
            "Bangladesh",
            "Benin",
            "Botswana",
            "Bulgaria",
            "Burundi",
            "Cameroon",
            "Cape Verde",
            "Chile",
            "Comoros",
            "Congo",
            "Costa Rica",
            "Cyprus",
            "Czech Republic",
            "Djibouti",
            "Dominica",
            "Dominican Republic",
            "Ecuador",
            "El Salvador",
            "Equatorial Guinea",
            "Eritrea",
            "Estonia",
            "Fiji Islands",
            "Finland",
            "France",
            "Gabon",
            "Gambia",
            "Ghana",
            "Greece",
            "Guatemala",
            "Guinea",
            "Guinea-Bissau",
            "Guyana",
            "Haiti",
            "Honduras",
            "Hungary",
            "Iceland",
            "Iraq",
            "Ireland",
            "Israel",
            "Italy",
            "Kenya",
            "Kiribati",
            "Kyrgyzstan",
            "Laos",
            "Latvia",
            "Lebanon",
            "Liberia",
            "Lithuania",
            "Macedonia",
            "Malawi",
            "Maldives",
            "Malta",
            "Marshall Islands",
            "Mauritius",
            "Moldova",
            "Mozambique",
            "Myanmar",
            "Namibia",
            "Nauru",
            "Nicaragua",
            "Pakistan",
            "Palau",
            "Panama",
            "Paraguay",
            "Philippines",
            "Poland",
            "Portugal",
            "Romania",
            "Rwanda",
            "Sao Tome and Principe",
            "Senegal",
            "Seychelles",
            "Sierra Leone",
            "Singapore",
            "Slovakia",
            "Slovenia",
            "Somalia",
            "South Korea",
            "Sri Lanka",
            "Suriname",
            "Syria",
            "Taiwan",
            "Tajikistan",
            "Tanzania",
            "Togo",
            "Trinidad and Tobago",
            "Tunisia",
            "Turkey",
            "Turkmenistan",
            "Uganda",
            "Uruguay",
            "Uzbekistan",
            "Vanuatu",
            "Yemen",
            "Zambia",
            "Zimbabwe"
        )

    }
}