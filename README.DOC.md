## Pre-Considerations

- no need to implement complex Routing, since you will display three pages inside a TabView
- no need for localization in the first place, make a .hardCoded extension on Strings
- is data preloading simply fetch all data at the beginning eagerly or is pagination per date required, since date filtering is mentioned?
    - → check out API
- caching will be done by Riverpod (Singleton/KeepAlive Provider per Page, should do the job)
    - refresh provider will do the data cache deletion
- User friendly error messages via Freezed
- Data Polling → Service will be required that triggers fetching every now and then → use streams from the beginning to bubble up data when requested
- robot testing?
- check out api → then a quick mock might make sense
- no need for flavors
- analyze api + fetch some data via postman
- show data per day, since this is a monitoring tool, i suggest it is more important to see daily data rather than data of multiple days
    - show the date at the top, add calendar icon to signal, that it is clickable to choose date
- BottomNavigationBar → User needs to Access the different Metrics without effort
    - they cant be positioned at the top, because the swipe would interfere with pageview/tabviews swipe for changing the date
- for the line-charts FL-Charts will be chosen, since it is open source and seems to be most popular
    - standard usecase therefore no need to build your own, especially considering the given time
        - possible downsides → Harder to fit into the Brand theme
- Thoughts regarding architecture
    - Option 1
        - Screen mit ScreenController → Data maintained here
            - centerlized structure → easier Data Polling, because Polling is only necessary for todays day ???
                - probably not because there will be more logic in one place, thus making it more complicated to maintain and test
            - data held in a map, in case of a pageview that might be more complex in terms of data updates
            - PageView
                - DayWidget
    - Option 2
        - Screen mit PageBucket for the State → the only data held here will be the dates that have been either preloaded or accessed by the user, so that daywidget get a dateparameter to initialize/get cached provider
            - PageView
                - **can you dynamically add pages to the page view without breaking the pageview? → very difficult**
                - DayWidget → Data hold here → decenterlized data structure
                    - stateful widget with AutomaticKeepAliveClientMixin or with a provider that will be disposed only after a certain amount of time → probably the better approach, since the data will be cleared and the app therefore more performant
                    - this requires a differentiation between DayWidgets for better functionality management
                        - separate widgets are necessary because riverpod does not support generics
                        - CurrentDateWidget → getting a currentDateProvider/Service
                        - HistoricDateWidget → getting a historicDateProvider/Service
                        - if there is enough time the daywidget could be extended to show data aggregations kw/h or sum etc. to make it feel even more like a dashboard
    - One Repository → EnergyMonitoringRepo with a parameter to determine the type
    - OneBaseScreen for the UI with Controller that knows what to instantiate based on a typeparameter
        - 3 Metric SpecificScreens determining and passing down the type of the metric
        - is that possibly with riverpod?
    - settings accessed via app bar
        - Polling intervall could be set there
        - Maybe hide Unit in the settings as well since it is a one time change and would otherwise add more unnecessary compexity to the UI
            - use a strategy pattern to display the data in the selcted data unit without adding logic to the model
            - a singleton strategy provider that is changed through the settings
        - theme change could be also placed inside settings
    
## Architecture explanation

- logic and fetching per metric type is the same, only the source differs by the actual url, meaning that it is sufficient to have Base Components, that are instantiated with the metric type to be able distinguish → so the code is modular
- currently no need to distinguish between models/dtos since the received data is brought to view
    - in case there would be some accumulated data, coming from different sources/dtos, it might make sense to distinguish between dtos coming from the API and models that go to the UI
- MonitoringPageController, when loaded or Page changing, preloads MonitoringWidgetControllers, so that when User swipes through it is ensured, the Data is Already there
    - this also allows for simple eager initialisation at App start, so that data that is anticipated as “of interest” is loaded, as part of the app start. Such app behaviour, meaning waiting at the beginning, is “known” to the user, meaning that this is less pain to the user, than waiting when the app already has opened
- Handle and show Errors as deep down as possible, where the actual errors happen, because it might be that date x was properly loaded, but date y not.
    - this also ensures that it is possible to refetch data only for dates where actually errors happened, which reduces time and increases performance. Furthermore it feels natural to the users
- Only specific dates are preloaded
    - we cant know which data will be of interest to the user, but it is most likely that only todays date is of interest, at most the last couple of days so that the user can do comparisons
        - this explains the PageView layout, rather than some accumulated View for multiple dates
        - also this assumption indicates that data, that once fetched does not need to be fetched longer than of interest
            - thats why the MonitoringWidgetController holds data for a n-amount of time (currently set to 5 min) and is then disposed, the actual time until disposal would need to be discussed based on actual user behaviour or product knowledge


## In the Process & Trade-Offs

- build the basic Scaffold and add a Chart with dummy data → this is necessary to check out the Chart Package’s capabilities and it’s ease of use to determine if it is suitable for the requirements
- had difficulties applying new state to the PageView, because state changes lead to rebuilding the whole PageView, this was due to using Riverpod AsyncLoading state, in that case the whole PageView was not in the Widget Tree anymore and when data came back it was build new → solution was to not rely on MonitorPageControllers Loading state when loading new pages
- PageView-Layouting
    - initial idea was to have a PageView at top showing the selected date that is controllable via left/right button, which also trigger the body(PageView with MonitoringWidgets)
    - besides that the Body PageView should also trigger the date PageView when swiping
    - both PageViews, should have dynamically created children based on the dates that user is swiping through
    - Due to difficulties of synchronising and additionally dynamically creating children and the time limitation it was not possible to implement the described behaviour
        - either only one of the PageViews triggered, or over-scrolling happened, or when tapping buttons to swipe the body PageView triggered twice
        - reducing the date PageView to a static Text, that changes, did the work, but because of that the UI - Feeling is reduced
    - P.S reducing complexity lead to rebuilding the dynamic structure of the pageview, by simple allowing a prefixed set of data i.e the last 2 years and additionally load data dynamically, like that there is no additional complecity meaning a better maintainable code
- sometimes it seems that values are negative or the conversion of model to chart emits negative values → probably a bug, due to time constraints not relevant for now
- planned architecture turned out to be very difficult in terms of testing, the whole idea of disposing controllers after some amount of time, so that data can be cached, turned out to not work in testing as expected when using the fake_async package like planned
- it turned out that the charts data is not recognisable in testing. I.e, you cant just verify that a certain label text is there, this is probably because the chart is drawn rather than a composition of widget, due to time constraints it could not be analyzed further, but depending on the libraries capacity, it technically could be possible to verify drawn component
    - business logic tests should verify the correct value
    - you need to “trust” the library for it’s promises, thats the reason famous and large packages are preferred over small and new one
