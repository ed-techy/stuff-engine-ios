// ------------ VERBOSE SECTIONS ------------ //

// iOS Helper verbose
#define IH_VERBOSE

////////////////////////////////////////////////


// ------------- NSLOG FORMATS ------------- //

#define SIMPLENSLOG

#if defined(SIMPLENSLOG)
    #define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#endif

////////////////////////////////////////////////