/* -*-c-*- *********************************************************/
/*******************************************************************/
/*******************************************************************/
/**
  This file is for threaded code.

  ----
  This file is auto generated by insns2vm.rb
  DO NOT TOUCH!

  If you want to fix something, you must edit 'template/optinsn.inc.tmpl'
  or rb/insns2vm.rb
 */

static INSN *
insn_operands_unification(INSN *insnobj){
#ifdef OPT_OPERANDS_UNIFICATION
  /* optimize rule */
  switch(insnobj->insn_id){



  default:
    /* do nothing */;
    break;
  }
#endif
  return insnobj;
}
