class DangerCheck {
  static bool purseShrinkDangerCheck(int shrink) {
    if(shrink >= 200) {
      return true;
    } else {
      return false;
    }
  }

  static bool purseRelaxDangerCheck(int relax) {
    if(relax >= 200) {
      return true;
    } else {
      return false;
    }
  }

  static bool glucoDangerCheck(int value, String name) {
    if(name == '식전' && value >= 170) {
      return true;
    }
    else if(name == '식후' && value >= 200) {
      return true;
    } else {
      return false;
    }
  }
}