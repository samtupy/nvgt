#include "print_func.h"
#include <string>
#include "scriptarray.h"
#include "scriptdictionary.h"
#include <cstring>
#include <angelscript.h>
#include <cinttypes>
#include <cassert>
#include <array>

#include <sstream>
#include <iostream>

Print::PrintNonPrimitiveType* Print::g_PrintRegisteredType{&Print::PrintAddonTypes};
Print::PrintNonPrimitiveType* Print::g_PrintScriptObjectType{nullptr};
class CScriptDictionary;

#define INS_1 "const ?&in = null"
#define INS_2 INS_1 ", " INS_1
#define INS_3 INS_2 ", " INS_1
#define INS_4 INS_2 ", " INS_2
#define INS_8 INS_4 ", " INS_4
#define INS_15 INS_8 ", " INS_4 ", " INS_3
#define INS_16 INS_8 ", " INS_8

#define OUTS_1 "?&out = null"
#define OUTS_2 OUTS_1 ", " OUTS_1
#define OUTS_3 OUTS_2 ", " OUTS_1
#define OUTS_4 OUTS_2 ", " OUTS_2
#define OUTS_8 OUTS_4 ", " OUTS_4
#define OUTS_15 OUTS_8 ", " OUTS_4 ", " OUTS_3
#define OUTS_16 OUTS_8 ", " OUTS_8

bool Print::PrintAddonTypes(std::ostream & dst, void const *objPtr, int typeId, int depth)
{
    auto ctx = asGetActiveContext();
    if(!ctx) return false;
    auto engine = ctx->GetEngine();

    int stringTypeId = engine->GetStringFactory();

    if(stringTypeId == typeId)
    {
        auto const& string = *((std::string const*)objPtr);
        dst << string;
        return true;
    }

    auto typeInfo = engine->GetTypeInfoById(typeId);

    if(depth < 2 && strcmp(typeInfo->GetName(), "array") == 0)
    {
        CScriptArray const* array{};

        if(typeId & asTYPEID_OBJHANDLE)
            array = *reinterpret_cast<CScriptArray * const*>(objPtr);
        else
            array = reinterpret_cast<CScriptArray const*>(objPtr);

        if(array->GetSize() == 0)
            dst << "[]";
        else
        {
            dst << "[";

            for(uint32_t i = 0; i < array->GetSize(); ++i)
            {
                Print::PrintTemplate(dst, array->At(i), array->GetElementTypeId(), depth+1);
                dst << ((i+1 == array->GetSize())? "]" : ", ");
            }
        }

        return true;
    }

    if(strcmp(typeInfo->GetName(), "dictionary") == 0)
    {
        CScriptDictionary const* dictionary{};

        if(typeId & asTYPEID_OBJHANDLE)
            dictionary = *reinterpret_cast<CScriptDictionary * const*>(objPtr);
        else
            dictionary = reinterpret_cast<CScriptDictionary const*>(objPtr);

        std::string indent(depth+1, '\t');

        dst << "{\n";

        bool printed = false;
        for(auto const& pair : *dictionary)
        {
            if(printed) dst << ",\n";
            printed = true;

            dst << indent << '"' << pair.GetKey() << "\":";
            Print::PrintTemplate(dst, pair.GetAddressOfValue(), pair.GetTypeId(), depth+1);
        }

        dst << '\n' << indent.substr(0, indent.size()-1) << '}';

        return true;
    }

    if(strcmp(typeInfo->GetName(), "dictionaryValue") == 0)
    {
        auto value = reinterpret_cast<CScriptDictValue const*>(objPtr);

        Print::PrintTemplate(dst, value->GetAddressOfValue(), value->GetTypeId(), depth+1);
    }

    return false;
}

void Print::PrintTemplate(std::ostream & dst, void const* objPtr, int typeId, int depth)
{
    switch(typeId)
    {
    case asTYPEID_VOID:		return;
    case asTYPEID_BOOL:		dst << ((*(bool const*)objPtr)? "true" : "false"); return;
    case asTYPEID_INT8:		dst <<  (int64_t)*(int8_t   const*)objPtr; return;
    case asTYPEID_INT16:	dst <<  (int64_t)*(int16_t  const*)objPtr; return;
    case asTYPEID_INT32:	dst << 	(int64_t)*(int32_t  const*)objPtr; return;
    case asTYPEID_INT64:	dst << 	(int64_t)*(int64_t  const*)objPtr; return;
    case asTYPEID_UINT8:	dst <<  (uint64_t)*(uint8_t  const*)objPtr; return;
    case asTYPEID_UINT16:	dst <<  (uint64_t)*(uint16_t const*)objPtr; return;
    case asTYPEID_UINT32:	dst <<  (uint64_t)*(uint32_t const*)objPtr; return;
    case asTYPEID_UINT64:	dst <<  (uint64_t)*(uint64_t const*)objPtr; return;
    case asTYPEID_FLOAT:	dst <<  (double)*(float    const*)objPtr; return;
    case asTYPEID_DOUBLE:	dst <<  (double)*(double   const*)objPtr; return;
    default: break;
    }

    auto ctx = asGetActiveContext();
    if(!ctx) return;
    auto engine = ctx->GetEngine();

    auto typeInfo = engine->GetTypeInfoById(typeId);

    if(!typeInfo)
    {
        dst << "BAD_TYPEID";
        return;
    }

    if(objPtr == nullptr)
    {
        dst << typeInfo->GetName();
        return;
    }

    if(typeInfo->GetFuncdefSignature())
    {
        auto func = reinterpret_cast<asIScriptFunction const*>(objPtr);
        dst << func->GetDeclaration(true, true, true);
        return;
    }

    auto enumValueCount = typeInfo->GetEnumValueCount();
    if(enumValueCount)
    {
        int value = *(uint32_t const*)objPtr;

        dst << typeInfo->GetName();

        for(uint32_t i = 0; i < enumValueCount; ++i)
        {
            int val;
            const char * text = typeInfo->GetEnumValueByIndex(i, &val);

            if(val == value)
            {
                dst << "::" << text;
            }
        }

        return;
    }

    if(typeId & asTYPEID_SCRIPTOBJECT)
    {
        if(g_PrintScriptObjectType && g_PrintScriptObjectType(dst, objPtr, typeId, depth))
            return;

        if(typeId & asTYPEID_OBJHANDLE)
        {
            dst << "@" << typeInfo->GetName() << "(" <<  *(void**)objPtr << ")";
        }
        else
        {
            dst << typeInfo->GetName() << "(" <<  objPtr << ")";
        }
    }

    if(typeId & (asTYPEID_APPOBJECT|asTYPEID_TEMPLATE))
    {
        if(g_PrintRegisteredType != nullptr)
        {
            if(typeId & asTYPEID_OBJHANDLE)
            {
                typeId &= ~(asTYPEID_OBJHANDLE|asTYPEID_HANDLETOCONST);
                objPtr = *(void**)objPtr;
            }

            if(g_PrintRegisteredType(dst, objPtr, typeId, depth))
                return;
        }

        dst << "RegisteredObject";

        return;
    }

    dst << "UNKNOWN";

    return;
}

void Print::PrintFormat(std::ostream & stream, std::string const& in, asIScriptGeneric * generic, int offset)
{
	int argc = generic->GetArgCount() - offset;
    if(argc <= 0)
    {
        stream << in;
        return;
    }

	for(size_t itr = 0, next = 0; itr < in.size(); itr = next)
    {
        next = in.find_first_of('%', itr);
        stream << in.substr(itr, next-itr);

        if(next == std::string::npos) break;

        if(!isdigit(in[++next]))
            stream << '%';
        else
        {
            auto arg = atoi(&in[next]) % argc;
            while(next < in.size() && isdigit(in[next])) ++next;

			Print::PrintTemplate(stream, generic->GetArgAddress(offset+arg), generic->GetArgTypeId(offset+arg), 0);
        }
    }
}

void Print::PrintFormatArray(std::ostream & stream, std::string const& in, CScriptArray* array, int offset)
{
	int argc = array->GetSize() - offset;
    if(argc <= 0)
    {
        stream << in;
        return;
    }

	for(size_t itr = 0, next = 0; itr < in.size(); itr = next)
    {
        next = in.find_first_of('%', itr);
        stream << in.substr(itr, next-itr);

        if(next == std::string::npos) break;

        if(!isdigit(in[++next]))
            stream << '%';
        else
        {
            auto arg = atoi(&in[next]) % argc;
            while(next < in.size() && isdigit(in[next])) ++next;

			Print::PrintTemplate(stream, array->At(offset+arg), array->GetElementTypeId(), 0);
        }
    }
}


void Print::PrintTemplate(std::ostream & stream, asIScriptGeneric * generic, int offset)
{
	for(int i = offset; i < generic->GetArgCount(); ++i)
	{
		void * ref = generic->GetArgAddress(i);
		int typeId = generic->GetArgTypeId(i);

		if(typeId)
			PrintTemplate(stream, ref, typeId, 0);
	}

}

static void PrintFunc(asIScriptGeneric * generic)
{
	Print::PrintTemplate(std::cout, generic, 0);
}

static void PrintFuncLn(asIScriptGeneric * generic)
{
	Print::PrintTemplate(std::cout, generic, 0);
    std::cout << std::endl;
}

static void PrettyPrinting(asIScriptGeneric * generic)
{
    std::stringstream ss;
	Print::PrintTemplate(ss, generic, 0);
	new((std::string*)generic->GetObject()) std::string(ss.str());
}

static void asPrintFormat(asIScriptGeneric * generic)
{
	Print::PrintFormat(std::cerr, *(std::string*)generic->GetArgObject(0), generic, 1);
}

static void PrettyPrintingF(asIScriptGeneric * generic)
{
    std::stringstream ss;
	Print::PrintFormat(ss, *(std::string*)generic->GetObject(), generic, 0);
	std::string result = ss.str();
	generic->SetReturnObject(&result);
}

static std::string PrettyPrintingArrayF(std::string* fmt, CScriptArray* elements)
{
    std::stringstream ss;
	Print::PrintFormatArray(ss, *fmt, elements, 0);
	return ss.str();
}

/*
static void ScanFormat(std::string const& in, IN_ARGS_16)
{
    std::array<std::pair<void const*, int>, 16> args{A_ARGS_16};

    Print::ScanFormat(std::cout, W_ARGS_16);
    std::cout << std::endl;
}
*/

void Print::asRegister(asIScriptEngine * engine, bool registerStdStringFormatter)
{
	union { int r; asERetCodes code; };

    if(registerStdStringFormatter)
    {
		r = engine->RegisterObjectBehaviour("string", asBEHAVE_CONSTRUCT,  "void f(const ?&in, " INS_15 ")",  asFUNCTION(PrettyPrinting), asCALL_GENERIC); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string format(string[]@ elements) const",  asFUNCTION(PrettyPrintingArrayF), asCALL_CDECL_OBJFIRST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string format(" INS_16 ") const",  asFUNCTION(PrettyPrintingF), asCALL_GENERIC); assert( r >= 0 );
    }

	r = engine->RegisterGlobalFunction("void print(" INS_16 ")", asFUNCTION(PrintFunc), asCALL_GENERIC);  assert(r == asALREADY_REGISTERED || r >= 0);
	r = engine->RegisterGlobalFunction("void println(" INS_16 ")", asFUNCTION(PrintFuncLn), asCALL_GENERIC);  assert(r == asALREADY_REGISTERED || r >= 0);

	r = engine->RegisterGlobalFunction("void printf(const string &in format, " INS_16 ")", asFUNCTION(asPrintFormat), asCALL_GENERIC);  assert(r == asALREADY_REGISTERED || r >= 0);
    //r = engine->RegisterGlobalFunction("void Scanf(const string &in format, " OUTS_16 ")", asFUNCTION(ScanFormat), asCALL_CDECL);  assert(r == asALREADY_REGISTERED || r >= 0);
}
