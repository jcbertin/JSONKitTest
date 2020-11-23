//
//  main.m
//  JSONKitTest
//
//  Created by Jean-Charles BERTIN on 11/22/20.
//

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import <dispatch/dispatch.h>
#import <mach/mach_time.h>

#import "JSONKit.h"

struct test_data_t {
    uint64_t    _min_latency;
    uint64_t    _max_latency;
    uint64_t    _cumul_latency;
    uint64_t    _count;
};


static double mach_time_to_microseconds(uint64_t mach_time) {
    static mach_timebase_info_data_t _clock_timebase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info(&_clock_timebase);
    });
    return (double) (mach_time * _clock_timebase.numer / _clock_timebase.denom) * 10e-3;
}


static void print_test_data(const char *prefix, const struct test_data_t *data) {
    printf("%s: min elapsed = %.3f\n", prefix, mach_time_to_microseconds(data->_min_latency));
    printf("%s: max elapsed = %f\n", prefix, mach_time_to_microseconds(data->_max_latency));
    printf("%s: mean elapsed = %f\n", prefix, mach_time_to_microseconds(data->_cumul_latency) / (double) data->_count);
}


int main(int argc, const char * argv[]) {
    if (argc < 3) {
        const char *p, *progname;
        progname = argv[0];
        if ((p = strrchr(progname, '/')) != NULL)
            progname = p+1;
        fprintf(stderr, "Usage: %s <count> </path/to/test.json>", progname);
        return EXIT_FAILURE;
    }
    
    const NSUInteger count = strtoul(argv[1], NULL, 0);
    struct test_data_t data = {._min_latency = UINT64_MAX, ._max_latency = 0, ._cumul_latency = 0, ._count = count};
    NSString* filePath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:argv[2]
                                                                                     length:strlen(argv[2])];
    NSData* jsonData = [NSData dataWithContentsOfFile:filePath];
    JSONDecoder* decoder = [[JSONDecoder alloc] init];
    
    for (NSUInteger i = count; i > 0; --i) @autoreleasepool {
        const uint64_t start = mach_absolute_time();
        id __attribute__((unused)) json = [decoder objectWithData:jsonData];
        uint64_t elapsed = mach_absolute_time() - start;
        if (data._min_latency > elapsed)
            data._min_latency = elapsed;
        if (data._max_latency < elapsed)
            data._max_latency = elapsed;
        data._cumul_latency += elapsed;
    }
    print_test_data("JSONKit decode", &data);

    putchar('\n');
    data = (struct test_data_t) {._min_latency = UINT64_MAX, ._max_latency = 0, ._cumul_latency = 0, ._count = count};
    
    for (NSUInteger i = count; i > 0; --i) @autoreleasepool {
        const uint64_t start = mach_absolute_time();
        id __attribute__((unused)) json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        uint64_t elapsed = mach_absolute_time() - start;
        if (data._min_latency > elapsed)
            data._min_latency = elapsed;
        if (data._max_latency < elapsed)
            data._max_latency = elapsed;
        data._cumul_latency += elapsed;
    }
    print_test_data("NSJSON decode", &data);

    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];

    putchar('\n');
    data = (struct test_data_t) {._min_latency = UINT64_MAX, ._max_latency = 0, ._cumul_latency = 0, ._count = count};
    
    for (NSUInteger i = count; i > 0; --i) @autoreleasepool {
        const uint64_t start = mach_absolute_time();
        NSData* __attribute__((unused)) json = [dict JSONData];
        uint64_t elapsed = mach_absolute_time() - start;
        if (data._min_latency > elapsed)
            data._min_latency = elapsed;
        if (data._max_latency < elapsed)
            data._max_latency = elapsed;
        data._cumul_latency += elapsed;
    }
    print_test_data("JSONKit encode", &data);

    putchar('\n');
    data = (struct test_data_t) {._min_latency = UINT64_MAX, ._max_latency = 0, ._cumul_latency = 0, ._count = count};
    
    for (NSUInteger i = count; i > 0; --i) @autoreleasepool {
        const uint64_t start = mach_absolute_time();
        NSData* __attribute__((unused)) json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
        uint64_t elapsed = mach_absolute_time() - start;
        if (data._min_latency > elapsed)
            data._min_latency = elapsed;
        if (data._max_latency < elapsed)
            data._max_latency = elapsed;
        data._cumul_latency += elapsed;
    }
    print_test_data("NSJSON encode", &data);
    
    NSData* json = [dict JSONDataWithOptions:JKSerializeOptionPretty error:NULL];
    [json writeToFile:@"out.json" atomically:NO];

    return EXIT_SUCCESS;
}
