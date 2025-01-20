class DangerCheck {
  static bool purseShrinkDangerCheck(int shrink) {
    if(shrink >= 130) {
      return true;
    } else {
      return false;
    }
  }

  static bool purseRelaxDangerCheck(int relax) {
    if(relax >= 90) {
      return true;
    } else {
      return false;
    }
  }

  static bool glucoDangerCheck(int value, String name) {
    if(name == '식전' && value >= 100) {
      return true;
    }
    else if(name == '식후' && value >= 140) {
      return true;
    } else {
      return false;
    }
  }
}