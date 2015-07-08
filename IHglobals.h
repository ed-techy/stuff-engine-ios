// ------------ VERBOSE SECTIONS ------------ //

// iOS Helper verbose
#define IH_VERBOSE true

////////////////////////////////////////////////


// ------------- NSLOG FORMATS ------------- //

#define SIMPLENSLOG

#if defined(SIMPLENSLOG)
    #define IHLog(CONTEXT, FORMAT, ...) if(CONTEXT)printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#endif

////////////////////////////////////////////////