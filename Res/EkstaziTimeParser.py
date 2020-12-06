import sys
import codecs

if __name__ == "__main__":
    AFile = "tmptimeA.csv"
    ECFile = "tmptimeEC.csv"
    if len(sys.argv) == 3:
        AFile = sys.argv[1]
        ECFile = sys.argv[2]
    ATime = 0
    ETime = 0
    CTime = 0
    classNum = 0
    try:
        with codecs.open(AFile, "r", encoding="utf8") as f:
            for line in f:
                ATime = int(line.strip()[:-1]) / 1000.0
    except:
        pass
    try:
        with codecs.open(ECFile, "r", encoding="utf8") as f:
            for line in f:
                classNum += 1
                ETime += int(line.strip().split(",")[0]) / 1000.0
                CTime += int(line.strip().split(",")[1]) / 1000.0
    except:
        pass
    print("{:.3f}".format(ATime) + "," +
          "{:.3f}".format(ETime) + "," +
          "{:.3f}".format(CTime) + "," +
          str(classNum) + ",")
