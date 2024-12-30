import 'package:get/get.dart';
import 'package:weather_app/app/components/custom_loading_overlay.dart';
import 'package:weather_app/app/data/models/weather_details_model.dart';

import '../../../../config/theme/my_theme.dart';
import '../../../../config/translations/localization_service.dart';
import '../../../../utils/constants.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/weather_model.dart';
import '../../../services/api_call_status.dart';
import '../../../services/base_client.dart';
import '../../../services/location_service.dart';
import '../views/widgets/location_dialog.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  var currentLanguage = LocalizationService.getCurrentLocal().languageCode;
  late WeatherModel currentWeather;
  List<WeatherModel> weatherArroundTheWorld = [];
  final dotIndicatorsId = 'DotIndicators';
  final themeId = 'Theme';
  ApiCallStatus apiCallStatus = ApiCallStatus.loading;
  var isLightTheme = MySharedPref.getThemeIsLight();
  var activeIndex = 1;
  bool isSearchFieldVisible = false;

  get days => null;

  @override
  void onInit() async {
    if (!await LocationService().hasLocationPermission()) {
      Get.dialog(const LocationDialog());
    } else {
      getUserLocation();
    }
    super.onInit();
  }

  void showSearchField() {
    isSearchFieldVisible = true;
    update(); // Notify listeners
  }

  void hideSearchField() {
    isSearchFieldVisible = false;
    update(); // Notify listeners
  }

  /// get the user location
  getUserLocation() async {
    var locationData = await LocationService().getUserLocation();
    if (locationData != null) {
      await getCurrentWeather(
          '${locationData.latitude},${locationData.longitude}');
    }
  }

  /// get home screem data (sliders, brands, and cars)
  getCurrentWeather(String location) async {
    await BaseClient.safeApiCall(
      Constants.currentWeatherApiUrl,
      RequestType.get,
      queryParameters: {
        Constants.key: Constants.apiKey,
        Constants.q: location,
        Constants.lang: currentLanguage,
      },
      onSuccess: (response) async {
        currentWeather = WeatherModel.fromJson(response.data);
        await getWeatherArroundTheWorld();
        apiCallStatus = ApiCallStatus.success;
        update();
      },
      onError: (error) {
        BaseClient.handleApiError(error);
        apiCallStatus = ApiCallStatus.error;
        update();
      },
    );
  }

  /// get weather arround the world
  getWeatherArroundTheWorld() async {
    weatherArroundTheWorld.clear();
    final cities = ['Rabat', 'Casablanca', 'Marrakech'];
    await Future.forEach(cities, (city) {
      BaseClient.safeApiCall(
        Constants.currentWeatherApiUrl,
        RequestType.get,
        queryParameters: {
          Constants.key: Constants.apiKey,
          Constants.q: city,
          Constants.lang: currentLanguage,
        },
        onSuccess: (response) {
          weatherArroundTheWorld.add(WeatherModel.fromJson(response.data));
          update();
        },
        onError: (error) => BaseClient.handleApiError(error),
      );
    });
  }

  /// when the user slide the weather card
  onCardSlided(index, reason) {
    activeIndex = index;
    update([dotIndicatorsId]);
  }

  /// when the user press on change theme icon
  onChangeThemePressed() {
    MyTheme.changeTheme();
    isLightTheme = MySharedPref.getThemeIsLight();
    update([themeId]);
  }

  /// when the user press on change language icon
  onChangeLanguagePressed() async {
    currentLanguage = currentLanguage == 'ar' ? 'en' : 'ar';
    await LocalizationService.updateLanguage(currentLanguage);
    apiCallStatus = ApiCallStatus.loading;
    update();
    await getUserLocation();
  }

  void searchWeather(String query) async {
    Get.toNamed('/weather', arguments: query);
  }

  // Get weather based on query
  Future<void> getWeatherDetails(String query) async {
    await showLoadingOverLay(
      asyncFunction: () async => await BaseClient.safeApiCall(
        Constants.forecastWeatherApiUrl,
        RequestType.get,
        queryParameters: {
          Constants.key: Constants.apiKey,
          Constants.q: query,
          Constants.days: days,
          Constants.lang: currentLanguage,
        },
        onSuccess: (response) {
          var weatherDetails = WeatherDetailsModel.fromJson(response.data);
          var forecastday = weatherDetails.forecast.forecastday[0];
          apiCallStatus = ApiCallStatus.success;
          update();
        },
        onError: (error) {
          BaseClient.handleApiError(error);
          apiCallStatus = ApiCallStatus.error;
          update();
        },
      ),
    );
  }
}
