from fastecdsa import keys, curve
from fastecdsa.curve import Curve
from fastecdsa.point import Point
"""The reason there are two ways to generate a keypair is that generating the public key requires
a point multiplication, which can be expensive. That means sometimes you may want to delay
generating the public key until it is actually needed."""
P = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
N = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001
R = 2 ** 256
def check(p: Point):
    print("check Point(x, y):")
    print(hex(p.x))
    print(hex(p.y))

def checkmont(p: Point):
    x = p.x * R % P
    print("mont field: " + hex(x))

newcurve = Curve(
    "bn128",
    0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47,
    0,
    3,
    0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001,
    0,
    0
)

Sbits = [2**64 - 1, 2 ** 128 - 2 ** 64, 2 ** 192 - 2 ** 128, 2 ** 256 - 2 ** 192]
DBCbits = 2**32 - 1

def getint(lis):
    bit = 2 ** 32
    ans = 0
    for n in lis:
        ans = ans * bit + n
    return ans


def printhex(n: int):
    print('{%sULL, %sULL, %sULL, %sULL}, ' % (hex(n & Sbits[0]), hex((n & Sbits[1]) >> 64), hex((n & Sbits[2]) >> 128), hex((n & Sbits[3]) >> 192)))


def printscalar(s: int):
    ans = list()
    while s > 0:
        ans.append(s & DBCbits)
        s = s >> 32
    ans.reverse()
    print('{%sU, %sU, %sU, %sU, %sU, %sU, %sU, %sU},' % (hex(ans[0]), hex(ans[1]), hex(ans[2]), hex(ans[3]), hex(ans[4]), hex(ans[5]), hex(ans[6]), hex(ans[7])))


def modinv(n:int, r:int, p:int):
    ans, base = 1, n
    while r > 0:
        if r % 2 == 1:
            ans = ans * base % p
        r = r // 2
        base = base * base % p
    return ans

gx = [15898858618418313115359640124759345094012678813232867496271511864746966797715,
356552093238573997433349584908974583469828003779246060794880275124975424087,
3246867293362207019552051541181939719897227582406940163960995086065518088828,
#0x1b6c15d87094c323ff7cf025debd97a24dc22b5a3f11662fa328d586cf210a56,
13851563428199941834235923517497004743025441141472054695944680048452683944337, ]


gy = [11437570662332107710739114712834026795906813647569147134848049504260827879478,
14903425531539517448969110523738496884487305501965662209176463541564061399690,
8032053207243838812043882064769351012973045641719591114691236998778075239480,
#0x2b7486f94876800e24a461b50e6dd9b339e0bfff7d301325ffeb5bc46abea047,
1531594432658598731560527921475674593449636905417765108207843071693731906629,]


scalar = [[205973761,655691475,3212678982,2780673202,246882742,3373203617,841114574,682807874,],
[536632485,1902021725,3931787030,1466379785,3621011277,3829202438,3671590951,1035836490,],
[620212549,3065768692,1435503988,305478975,1959887294,3793047713,789517499,740981894,],
#[172841775, 3386606474, 1934459325, 3068368335, 4015241023, 2577226107, 234330151, 2519017457],
[0x7a4ef511a2d23c4d75e67936452e002634fd4b44bdb6cba27475f39e377]]


x=[0x23e945246f2df499, 0x2a4c53ee85a5ca21, 0x74eee823d22a6a99, 0x074d6724dd45ae9f,      ]
y=[ 0x93789d6392a03e01, 0x2f1861ad22b92aff, 0xff1c705bcdee20f8, 0x12fdb5561239d35d,      ]
z=[ 0, 0, 0, 1]
xint, yint, zint = 0, 0, 0
bit = 2 ** 64
base = 2 ** 192
for i in range(0, 4):
    xint += x[i] * bit
    yint += y[i] * bit
    zint += z[i] * bit
    base = base // bit
zinv = modinv(zint, P - 2, P)
print("test: %d" % (zint * zinv % P))
print("test: %d, %d" % (yint * yint * zint % P, (xint ** 3 + 3 * zint ** 3) % P ))
xint = xint * zinv * zinv % P
yint = yint * zinv * zinv * zinv % P
print("%d %d\n" % (xint, yint))
#gx.append(xint)
#gy.append(yint)

print("test scalar:")
printscalar(6372386556686769622890859855701078758925290218000516478393422847754998105734)

scalarint = [getint(s) for s in scalar]

for x in gx:
    printhex(x)

for y in gy:
    printhex(y)

for s in scalarint:
    print(hex(s))
    printscalar(s)


rawp = [Point(gx[i], gy[i], curve=newcurve) for i in range(0, 4)]
ans = [scalarint[i] * rawp[i] for i in range(0, 4)]

for p in ans:
    check(p)

'''
0x074d6724dd45ae9f74eee823d22a6a992a4c53ee85a5ca2123e945246f2df499
0x12fdb5561239d35dff1c705bcdee20f82f1861ad22b92aff93789d6392a03e01
0x1936cb79dd4771e4  0x6270a195ae1995e8  0x09f654ac17dbbb37  0xf706069f0c9c6fb5
0x0e9028dd9eecd77b  0x5f237299744dc16a  0x0a4ff1f71ab2af88  0x53f9df8cf83e51dd
0x074d6724dd45ae9f  0x74eee823d22a6a99  0x2a4c53ee85a5ca21  0x23e945246f2df499
0x12fdb5561239d35d  0xff1c705bcdee20f8  0x2f1861ad22b92aff  0x93789d6392a03e01
0x1936cb79dd4771e4  0x6270a195ae1995e8  0x09f654ac17dbbb37  0xf706069f0c9c6fb5
0x0e9028dd9eecd77b  0x5f237299744dc16a  0x0a4ff1f71ab2af88  0x53f9df8cf83e51dd
'''
addp2 = [0x1936cb79dd4771e46270a195ae1995e809f654ac17dbbb37f706069f0c9c6fb5,
0x0e9028dd9eecd77b5f237299744dc16a0a4ff1f71ab2af8853f9df8cf83e51dd]
addp1 = [0x074d6724dd45ae9f74eee823d22a6a992a4c53ee85a5ca2123e945246f2df499,0x12fdb5561239d35dff1c705bcdee20f82f1861ad22b92aff93789d6392a03e01]


addP1 = Point(addp1[0], addp1[1], curve=newcurve)
addP2 = Point(addp2[0], addp2[1], curve=newcurve)
check(addP1 + addP2)