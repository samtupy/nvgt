#ifndef PRINT_FUNC_H
#define PRINT_FUNC_H
#include <string>

#if AS_USE_NAMESPACE
namespace AngelScript { class asIScriptEngine; }
#else
class asIScriptEngine;
class asIScriptGeneric;
#endif

namespace Print
{
#if AS_USE_NAMESPACE
typedef AngelScript::asIScriptEngine asIScriptEngine;
#else
typedef ::asIScriptEngine asIScriptEngine;
#endif

typedef bool PrintNonPrimitiveType(std::ostream & dst, void const *objPtr, int typeId, int depth);

//defaults to PrintAddonTypes
extern PrintNonPrimitiveType* g_PrintRegisteredType;
//defaults to printing the address
extern PrintNonPrimitiveType* g_PrintScriptObjectType;

void PrintTemplate(std::ostream & dst, void const *objPtr, int typeId, int depth = 0);
void PrintFormat(std::ostream & stream, std::string const& in, asIScriptGeneric * generic, int offset = 0);
void PrintTemplate(std::ostream & stream, asIScriptGeneric * generic, int offset = 0);

//currently only string and array
bool PrintAddonTypes(std::ostream & dst, void const *objPtr, int typeId, int depth);


void asRegister( asIScriptEngine * engine, bool registerStdStringFormatter = true);

};



#endif // PRINT_FUNC_H
