
#include "JJUtilities.h"

FILE *LogFileDesc;

FILE* getLogFileDesc(){
    return LogFileDesc;
}

void setLogFileDesc(FILE* desc){
    LogFileDesc = desc;
}

void JJLog(NSString* format, ...)
{
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    NSLog(@"%@", formattedMessage);
    fprintf(LogFileDesc, "%s\n", [formattedMessage UTF8String]);
}
