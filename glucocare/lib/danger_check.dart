class DangerCheck {
  static bool purseShrinkDangerCheck(int shrink) {
    if(shrink >= 130) return true;
    else return false;
  }

  static bool purseRelaxDangerCheck(int relax) {
    if(relax >= 90) return true;
    else return false;
  }

  static bool glucoDangerCheck(int value) {
    if(value >= 126) return true;
    else return false;
  }
}