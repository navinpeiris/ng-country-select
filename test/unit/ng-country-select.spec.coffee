describe 'ng-country-select', ->
  beforeEach ->
    jasmine.addMatchers
      toBeEmpty: ->
        compare: (actual) ->
          pass: actual.length == 0
          message: "Expected #{actual} to be empty"
        negativeCompare: (actual) ->
          pass: actual.length != 0
          message: "Expected #{actual} not to be empty"

  describe 'directive', ->
    scope = null
    isolateScope = null
    compile = null
    element = null

    beforeEach module 'countrySelect'
    beforeEach inject ($rootScope, $compile) ->
      scope = $rootScope.$new()
      compile = $compile

      scope.selectedCountry = 'AU'

    compileSource = (source) ->
      element = compile(source)(scope);
      scope.$digest()

      isolateScope = element.isolateScope()

    allCountriesCount = 250
    includingOptionalCount = allCountriesCount + 1
    basicSource = '<country-select ng-model="selectedCountry"></country-select>'

    firstOption = -> element.find('option')[0]

    describe 'basic usage', ->
      beforeEach -> compileSource basicSource

      it 'sets the list of countries in the directives scope', ->
        expect(isolateScope.countries).toBeDefined()
        expect(isolateScope.countries.length).toEqual allCountriesCount

      it 'replaces the directive element with a select', ->
        expect(element[0].nodeName).toEqual 'SELECT'

      it 'populates the select with options', ->
        expect(element.find('option').length).toEqual includingOptionalCount

    describe 'with required attribute', ->
      describe 'when not specified', ->
        beforeEach -> compileSource basicSource

        it 'sets the isSelectionOptional flag in scope to be true', ->
          expect(isolateScope.isSelectionOptional).toBeDefined()
          expect(isolateScope.isSelectionOptional).toBe true

        it 'sets the first option to be an empty option', ->
          expect(firstOption().value).toEqual ''
          expect(firstOption().textContent).toEqual ''

      describe 'when specified', ->
        beforeEach -> compileSource '<country-select ng-model="selectedCountry" cs-required></country-select>'

        it 'sets the isSelectionOptional flag in scope to be false', ->
          expect(isolateScope.isSelectionOptional).toBeDefined()
          expect(isolateScope.isSelectionOptional).toBe false

        it 'sets the first option to be the first country', ->
          expect(firstOption().value).toEqual '0'
          expect(firstOption().textContent).toEqual 'Afghanistan'

    describe 'with priority countries specified', ->
      beforeEach -> compileSource '<country-select ng-model="selectedCountry" cs-priorities="AU, GB , US"></country-select>'

      it 'sets the priority elements in the order specified at the start of the list', ->
        expect(isolateScope.countries[0].code).toEqual 'AU'
        expect(isolateScope.countries[1].code).toEqual 'GB'
        expect(isolateScope.countries[2].code).toEqual 'US'

      it 'adds a separator after the priority items', ->
        expect(isolateScope.countries[3].code).toEqual '-'
        expect(isolateScope.countries[3].name).toEqual '────────────────────'
        expect(isolateScope.countries[3].disabled).toEqual true

    # TODO: FIXME: Requires Angular 1.4 to get this done
    #        expect(element.find('option')[4].textContent).toEqual '────────────────────'
    #        expect(element.find('option')[4].disabled).toEqual true

    describe 'with only option specified', ->
      beforeEach -> compileSource '<country-select ng-model="selectedCountry" cs-only="AU, GB , US"></country-select>'

      it 'only contains the countries specified in the list in the order given', ->
        expect(isolateScope.countries.length).toEqual 3

        expect(isolateScope.countries[0].code).toEqual 'AU'
        expect(isolateScope.countries[1].code).toEqual 'GB'
        expect(isolateScope.countries[2].code).toEqual 'US'

    describe 'with except option specified', ->
      beforeEach -> compileSource '<country-select ng-model="selectedCountry" cs-except="AU, GB , US"></country-select>'

      it 'does not contain the specified countries', ->
        expect(isolateScope.countries.length).toEqual (allCountriesCount - 3)

        includedCountries = country.code for country in isolateScope.countries

        expect(includedCountries.indexOf('AU')).toEqual -1
        expect(includedCountries.indexOf('GB')).toEqual -1
        expect(includedCountries.indexOf('US')).toEqual -1
