import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  const CountrySearchListWidget(
    this.countries,
    this.locale, {
    this.searchBoxDecoration,
    this.scrollController,
    this.showFlags,
    this.useEmoji,
    this.autoFocus = false,
  });
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final String? locale;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool? showFlags;
  final bool? useEmoji;

  @override
  _CountrySearchListWidgetState createState() => _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  late final TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    final String value = _searchController.text.trim();
    filteredCountries = Utils.filterCountries(
      countries: widget.countries,
      locale: widget.locale,
      value: value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns [InputDecoration] of the search box
  InputDecoration getSearchBoxDecoration() =>
      widget.searchBoxDecoration ?? const InputDecoration(labelText: 'Search by country name or dial code');

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextFormField(
              key: const Key(TestHelper.CountrySearchInputKeyValue),
              decoration: getSearchBoxDecoration(),
              controller: _searchController,
              autofocus: widget.autoFocus,
              onChanged: (value) {
                final String value = _searchController.text.trim();
                return setState(
                  () => filteredCountries = Utils.filterCountries(
                    countries: widget.countries,
                    locale: widget.locale,
                    value: value,
                  ),
                );
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              controller: widget.scrollController,
              shrinkWrap: true,
              itemCount: filteredCountries.length,
              itemBuilder: (BuildContext context, int index) {
                final Country country = filteredCountries[index];

                return DirectionalCountryListTile(
                  country: country,
                  locale: widget.locale,
                  showFlags: widget.showFlags!,
                  useEmoji: widget.useEmoji!,
                );
                // return ListTile(
                //   key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
                //   leading: widget.showFlags!
                //       ? _Flag(country: country, useEmoji: widget.useEmoji)
                //       : null,
                //   title: Align(
                //     alignment: AlignmentDirectional.centerStart,
                //     child: Text(
                //       '${Utils.getCountryName(country, widget.locale)}',
                //       textDirection: Directionality.of(context),
                //       textAlign: TextAlign.start,
                //     ),
                //   ),
                //   subtitle: Align(
                //     alignment: AlignmentDirectional.centerStart,
                //     child: Text(
                //       '${country.dialCode ?? ''}',
                //       textDirection: TextDirection.ltr,
                //       textAlign: TextAlign.start,
                //     ),
                //   ),
                //   onTap: () => Navigator.of(context).pop(country),
                // );
              },
            ),
          ),
        ],
      );

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class DirectionalCountryListTile extends StatelessWidget {
  const DirectionalCountryListTile({
    required this.country,
    required this.locale,
    required this.showFlags,
    required this.useEmoji,
    super.key,
  });
  final Country country;
  final String? locale;
  final bool showFlags;
  final bool useEmoji;

  @override
  Widget build(BuildContext context) => ListTile(
        key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
        leading: (showFlags ? _Flag(country: country, useEmoji: useEmoji) : null),
        title: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '${Utils.getCountryName(country, locale)}',
            textDirection: Directionality.of(context),
            textAlign: TextAlign.start,
          ),
        ),
        subtitle: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            country.dialCode ?? '',
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
          ),
        ),
        onTap: () => Navigator.of(context).pop(country),
      );
}

class _Flag extends StatelessWidget {
  const _Flag({super.key, this.country, this.useEmoji});
  final Country? country;
  final bool? useEmoji;

  @override
  Widget build(BuildContext context) => country != null
      ? Container(
          child: useEmoji!
              ? Text(
                  Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
                  style: Theme.of(context).textTheme.headlineSmall,
                )
              : country?.flagUri != null
                  ? CircleAvatar(
                      backgroundImage: AssetImage(
                        country!.flagUri,
                        package: 'intl_phone_number_input',
                      ),
                    )
                  : const SizedBox.shrink(),
        )
      : const SizedBox.shrink();
}
