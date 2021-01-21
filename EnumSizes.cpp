/** Simple example code to demonstrate the GCC compiler's "interim" type (a bit field) of an
 *  enumaration versus the ultimate type of the enumeration (typically an `int`).
 */
#include <iostream>
using namespace std;

enum Enum1_1Val
{
    enum1_1,
};

enum Enum2_3Vals
{
    enum2_1,
    enum2_2,
    enum2_3,
};

enum Enum3_5Vals
{
    enum3_1,
    enum3_2,
    enum3_3,
    enum3_4,
    enum3_5,
};

enum Enum4_5Vals : uint8_t
{
    enum4_1,
    enum4_2,
    enum4_3,
    enum4_4,
    enum4_5,
};

int main()
{
    cout << "sizeof(Enum1_1Val)=" << sizeof(Enum1_1Val) << endl;
    Enum1_1Val e1a = static_cast<Enum1_1Val>(1);
    cout << "e1a=" << e1a << endl;
    Enum1_1Val e1b = (Enum1_1Val)2;
    cout << "e1b=" << e1b << endl << endl;

    cout << "sizeof(Enum2_3Vals)=" << sizeof(Enum2_3Vals) << endl;
    Enum2_3Vals e2a = static_cast<Enum2_3Vals>(3);
    cout << "e2a=" << e2a << endl;
    Enum2_3Vals e2b = static_cast<Enum2_3Vals>(4);
    cout << "e2b=" << e2b << endl << endl;

    cout << "sizeof(Enum3_5Vals)=" << sizeof(Enum3_5Vals) << endl;
    Enum3_5Vals e3a = (Enum3_5Vals)7;
    cout << "e3a=" << e3a << endl;
    Enum3_5Vals e3b = (Enum3_5Vals)8;
    cout << "e3b=" << e3b << endl << endl;

    cout << "sizeof(Enum4_5Vals)=" << sizeof(Enum4_5Vals) << endl;
    Enum4_5Vals e4a = static_cast<Enum4_5Vals>(8);
    cout << "e4a=" << e4a << endl;
    Enum4_5Vals e4b = static_cast<Enum4_5Vals>(256);
    cout << "e4b=" << e4b << endl << endl;

    return 0;
}
