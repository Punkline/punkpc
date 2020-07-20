import sys, os, tkinter
from tkinter import messagebox

# --- Options:

SHOW_PROMPTS = True
# will work silently without messages if False

VALID_EXTENSIONS = ('s', 'asm')
# only these files will be considered from input list, ignoring others
# - directories will also be searched, but not subdirectories within a given directory

EXCLUDED_FILENAME_PREFIXES = ('_proto_', '_outline_', '_scratch_')
# skip formatting files that start with these prefixes

OUTPUT_DIR = './output'
# all outputs are written to the same folder
INPUT_DIR = ''
# if not blank, only sys.argv[1:] is used, for passing file paths as arguments to the script

# input and output dirs can be set from the command line by enquoting 'in: dir' or 'out: dir'
# ./ = current working directory
# ../ = up dir
# ../../mydir = up dir *2, to 'mydir'

REFLOW_WIDTH = 99
# - set to a positive number to create a maximum character width allowed per line (concatenating by semicolons
# - set to 0 to force all lines to be on a new line
# - set to a negative number to virtually disable reflow width

SEMICOL = ''
COMMA   = ' '
INDENT  = '  '
# these whitespaces will be used in place of every comma, semicolon, and newline
# - other whitespace will be removed, or trimmed to only one space

USE_ARGDEF_WS = True
ARGDEF_WS = '  '
# lines that start with indent keywords will have their comma-separated arguments and semicolon use this whitespace

ENABLE_NEWLINE_KEYWORDS = True
FORCE_NEXT_NEWLINE_KEYWORDS = ('<', '>')
# lines that contain these keywords will end with a new line
# - defaults '<', '>' are used to prevent unlikely-but-possible .altmacro mode syntax complications

ENABLE_NEWLINE_PREFIXES = True
FORCE_THIS_NEWLINE_PREFIXES = ('.endm', '.macro', '.include ', '.if', '.else', '.rept ', '.irp')
# lines that start with these will start a new line
FORCE_NEXT_NEWLINE_PREFIXES = ('LOCAL', '.include ')
# lines that end with these will start a new line
# - default 'LOCAL' is used to prevent an error in GAS that hangs on semicolons when parsed as part of args for LOCAL

ENABLE_INDENTATION = True
INDENT_PREFIXES = ('.macro ', '.if', '.else', '.rept ', '.irp')
OUTDENT_PREFIXES = ('.endm', '.endif', '.else', '.endr')
# indentation does not create newlines unless assigned to a list of newline keywords/prefixes
CONCAT_NL_OUTDENT = True
# this will cause newline outdents to be concatenated with newline indents/outdents that immediately follow

ENDLINE_SEMICOL = True
# end reflowed lines with a semicolon before committing to a newline
# - in rare circumsntances involving evaluations of future-evaluable values,
#    this can be used to prevent a GAS parsing bug that fails to correctly interpret if-blocks
ENDLINE_SEMICOL_ONLY_OUTDENTS = True

INSTRUCTION_NEWLINES = True
# if True, all of the following keywords will invoke newlines in the reflow logic:
INSTRUCTION_KEYWORDS = ('add', 'add.', 'addc', 'addc.', 'addco', 'addco.', 'adde', 'adde.', 'addeo', 'addeo.', 'addi',
                        'addic', 'addic.', 'addis', 'addme', 'addme.', 'addmeo', 'addmeo.', 'addo', 'addo.', 'addze',
                        'addze.', 'addzeo', 'addzeo.', 'and', 'and.', 'andc', 'andc.', 'andi.', 'andis.', 'b', 'ba',
                        'bc', 'bc+', 'bc-', 'bca', 'bca+', 'bca-', 'bcctr', 'bcctr+', 'bcctr-', 'bcctrl', 'bcctrl+',
                        'bcctrl-', 'bcl', 'bcl+', 'bcl-', 'bcla', 'bcla+', 'bcla-', 'bclr', 'bclr+', 'bclr-', 'bclrl',
                        'bclrl+', 'bclrl-', 'bctar+', 'bctar-', 'bctarl+', 'bctarl-', 'bctr', 'bctrl', 'bdnz', 'bdnz+',
                        'bdnz-', 'bdnza', 'bdnza+', 'bdnza-', 'bdnzf', 'bdnzf+', 'bdnzf-', 'bdnzfa', 'bdnzfa+',
                        'bdnzfa-', 'bdnzfl', 'bdnzfl+', 'bdnzfl-', 'bdnzfla', 'bdnzfla+', 'bdnzfla-', 'bdnzflr',
                        'bdnzflr+', 'bdnzflr-', 'bdnzflrl', 'bdnzflrl+', 'bdnzflrl-', 'bdnzl', 'bdnzl+', 'bdnzl-',
                        'bdnzla', 'bdnzla+', 'bdnzla-', 'bdnzlr', 'bdnzlr+', 'bdnzlr+', 'bdnzlr-', 'bdnzlr-', 'bdnzlrl',
                        'bdnzlrl+', 'bdnzlrl+', 'bdnzlrl-', 'bdnzlrl-', 'bdnzt', 'bdnzt+', 'bdnzt-', 'bdnzta',
                        'bdnzta+', 'bdnzta-', 'bdnztl', 'bdnztl+', 'bdnztl-', 'bdnztla', 'bdnztla+', 'bdnztla-',
                        'bdnztlr', 'bdnztlr+', 'bdnztlr-', 'bdnztlrl', 'bdnztlrl+', 'bdnztlrl-', 'bdz', 'bdz+',
                        'bdz-', 'bdza', 'bdza+', 'bdza-', 'bdzf', 'bdzf+', 'bdzf-', 'bdzfa', 'bdzfa+', 'bdzfa-',
                        'bdzfl', 'bdzfl+', 'bdzfl-', 'bdzfla', 'bdzfla+', 'bdzfla-', 'bdzflr', 'bdzflr+', 'bdzflr-',
                        'bdzflrl', 'bdzflrl+', 'bdzflrl-', 'bdzl', 'bdzl+', 'bdzl-', 'bdzla', 'bdzla+', 'bdzla-',
                        'bdzlr', 'bdzlr+', 'bdzlr+', 'bdzlr-', 'bdzlr-', 'bdzlrl', 'bdzlrl+', 'bdzlrl+', 'bdzlrl-',
                        'bdzlrl-', 'bdzt', 'bdzt+', 'bdzt-', 'bdzta', 'bdzta+', 'bdzta-', 'bdztl', 'bdztl+', 'bdztl-',
                        'bdztla', 'bdztla+', 'bdztla-', 'bdztlr', 'bdztlr+', 'bdztlr-', 'bdztlrl', 'bdztlrl+',
                        'bdztlrl-', 'beq', 'beq+', 'beq-', 'beqa', 'beqa+', 'beqa-', 'beqctr', 'beqctr+', 'beqctr+',
                        'beqctr-', 'beqctr-', 'beqctrl', 'beqctrl+', 'beqctrl+', 'beqctrl-', 'beqctrl-', 'beql',
                        'beql+', 'beql-', 'beqla', 'beqla+', 'beqla-', 'beqlr', 'beqlr+', 'beqlr+', 'beqlr-', 'beqlr-',
                        'beqlrl', 'beqlrl+', 'beqlrl+', 'beqlrl-', 'beqlrl-', 'bf', 'bf+', 'bf-', 'bfa', 'bfa+',
                        'bfa-', 'bfctr', 'bfctr+', 'bfctr+', 'bfctr-', 'bfctr-', 'bfctrl', 'bfctrl+', 'bfctrl+',
                        'bfctrl-', 'bfctrl-', 'bfl', 'bfl+', 'bfl-', 'bfla', 'bfla+', 'bfla-', 'bflr', 'bflr+',
                        'bflr+', 'bflr-', 'bflr-', 'bflrl', 'bflrl+', 'bflrl+', 'bflrl-', 'bflrl-', 'bge', 'bge+',
                        'bge-', 'bgea', 'bgea+', 'bgea-', 'bgectr', 'bgectr+', 'bgectr+', 'bgectr-', 'bgectr-',
                        'bgectrl', 'bgectrl+', 'bgectrl+', 'bgectrl-', 'bgectrl-', 'bgel', 'bgel+', 'bgel-', 'bgela',
                        'bgela+', 'bgela-', 'bgelr', 'bgelr+', 'bgelr+', 'bgelr-', 'bgelr-', 'bgelrl', 'bgelrl+',
                        'bgelrl+', 'bgelrl-', 'bgelrl-', 'bgt', 'bgt+', 'bgt-', 'bgta', 'bgta+', 'bgta-', 'bgtctr',
                        'bgtctr+', 'bgtctr+', 'bgtctr-', 'bgtctr-', 'bgtctrl', 'bgtctrl+', 'bgtctrl+', 'bgtctrl-',
                        'bgtctrl-', 'bgtl', 'bgtl+', 'bgtl-', 'bgtla', 'bgtla+', 'bgtla-', 'bgtlr', 'bgtlr+', 'bgtlr+',
                        'bgtlr-', 'bgtlr-', 'bgtlrl', 'bgtlrl+', 'bgtlrl+', 'bgtlrl-', 'bgtlrl-', 'bl', 'bla', 'ble',
                        'ble+', 'ble-', 'blea', 'blea+', 'blea-', 'blectr', 'blectr+', 'blectr+', 'blectr-', 'blectr-',
                        'blectrl', 'blectrl+', 'blectrl+', 'blectrl-', 'blectrl-', 'blel', 'blel+', 'blel-', 'blela',
                        'blela+', 'blela-', 'blelr', 'blelr+', 'blelr+', 'blelr-', 'blelr-', 'blelrl', 'blelrl+',
                        'blelrl+', 'blelrl-', 'blelrl-', 'blr', 'blrl', 'blt', 'blt+', 'blt-', 'blta', 'blta+',
                        'blta-', 'bltctr', 'bltctr+', 'bltctr+', 'bltctr-', 'bltctr-', 'bltctrl', 'bltctrl+',
                        'bltctrl+', 'bltctrl-', 'bltctrl-', 'bltl', 'bltl+', 'bltl-', 'bltla', 'bltla+', 'bltla-',
                        'bltlr', 'bltlr+', 'bltlr+', 'bltlr-', 'bltlr-', 'bltlrl', 'bltlrl+', 'bltlrl+', 'bltlrl-',
                        'bltlrl-', 'bne', 'bne+', 'bne-', 'bnea', 'bnea+', 'bnea-', 'bnectr', 'bnectr+', 'bnectr+',
                        'bnectr-', 'bnectr-', 'bnectrl', 'bnectrl+', 'bnectrl+', 'bnectrl-', 'bnectrl-', 'bnel',
                        'bnel+', 'bnel-', 'bnela', 'bnela+', 'bnela-', 'bnelr', 'bnelr+', 'bnelr+', 'bnelr-', 'bnelr-',
                        'bnelrl', 'bnelrl+', 'bnelrl+', 'bnelrl-', 'bnelrl-', 'bng', 'bng+', 'bng-', 'bnga', 'bnga+',
                        'bnga-', 'bngctr', 'bngctr+', 'bngctr+', 'bngctr-', 'bngctr-', 'bngctrl', 'bngctrl+',
                        'bngctrl+', 'bngctrl-', 'bngctrl-', 'bngl', 'bngl+', 'bngl-', 'bngla', 'bngla+', 'bngla-',
                        'bnglr', 'bnglr+', 'bnglr+', 'bnglr-', 'bnglr-', 'bnglrl', 'bnglrl+', 'bnglrl+', 'bnglrl-',
                        'bnglrl-', 'bnl', 'bnl+', 'bnl-', 'bnla', 'bnla+', 'bnla-', 'bnlctr', 'bnlctr+', 'bnlctr+',
                        'bnlctr-', 'bnlctr-', 'bnlctrl', 'bnlctrl+', 'bnlctrl+', 'bnlctrl-', 'bnlctrl-', 'bnll',
                        'bnll+', 'bnll-', 'bnlla', 'bnlla+', 'bnlla-', 'bnllr', 'bnllr+', 'bnllr+', 'bnllr-', 'bnllr-',
                        'bnllrl', 'bnllrl+', 'bnllrl+', 'bnllrl-', 'bnllrl-', 'bns', 'bns+', 'bns-', 'bnsa', 'bnsa+',
                        'bnsa-', 'bnsctr', 'bnsctr+', 'bnsctr+', 'bnsctr-', 'bnsctr-', 'bnsctrl', 'bnsctrl+',
                        'bnsctrl+', 'bnsctrl-', 'bnsctrl-', 'bnsl', 'bnsl+', 'bnsl-', 'bnsla', 'bnsla+', 'bnsla-',
                        'bnslr', 'bnslr+', 'bnslr+', 'bnslr-', 'bnslr-', 'bnslrl', 'bnslrl+', 'bnslrl+', 'bnslrl-',
                        'bnslrl-', 'bnu', 'bnu+', 'bnu-', 'bnua', 'bnua+', 'bnua-', 'bnuctr', 'bnuctr+', 'bnuctr+',
                        'bnuctr-', 'bnuctr-', 'bnuctrl', 'bnuctrl+', 'bnuctrl+', 'bnuctrl-', 'bnuctrl-', 'bnul',
                        'bnul+', 'bnul-', 'bnula', 'bnula+', 'bnula-', 'bnulr', 'bnulr+', 'bnulr+', 'bnulr-', 'bnulr-',
                        'bnulrl', 'bnulrl+', 'bnulrl+', 'bnulrl-', 'bnulrl-', 'bso', 'bso+', 'bso-', 'bsoa', 'bsoa+',
                        'bsoa-', 'bsoctr', 'bsoctr+', 'bsoctr+', 'bsoctr-', 'bsoctr-', 'bsoctrl', 'bsoctrl+',
                        'bsoctrl+', 'bsoctrl-', 'bsoctrl-', 'bsol', 'bsol+', 'bsol-', 'bsola', 'bsola+', 'bsola-',
                        'bsolr', 'bsolr+', 'bsolr+', 'bsolr-', 'bsolr-', 'bsolrl', 'bsolrl+', 'bsolrl+', 'bsolrl-',
                        'bsolrl-', 'bt', 'bt+', 'bt-', 'bta', 'bta+', 'bta-', 'btctr', 'btctr+', 'btctr+', 'btctr-',
                        'btctr-', 'btctrl', 'btctrl+', 'btctrl+', 'btctrl-', 'btctrl-', 'btl', 'btl+', 'btl-', 'btla',
                        'btla+', 'btla-', 'btlr', 'btlr+', 'btlr+', 'btlr-', 'btlr-', 'btlrl', 'btlrl+', 'btlrl+',
                        'btlrl-', 'btlrl-', 'bun', 'bun+', 'bun-', 'buna', 'buna+', 'buna-', 'bunctr', 'bunctr+',
                        'bunctr+', 'bunctr-', 'bunctr-', 'bunctrl', 'bunctrl+', 'bunctrl+', 'bunctrl-', 'bunctrl-',
                        'bunl', 'bunl+', 'bunl-', 'bunla', 'bunla+', 'bunla-', 'bunlr', 'bunlr+', 'bunlr+', 'bunlr-',
                        'bunlr-', 'bunlrl', 'bunlrl+', 'bunlrl+', 'bunlrl-', 'bunlrl-', 'clrlwi', 'clrlwi.', 'cmp',
                        'cmp', 'cmpi', 'cmpi', 'cmpl', 'cmpl', 'cmpli', 'cmpli', 'cmplw', 'cmplwi', 'cmpw', 'cmpwi',
                        'cntlzw', 'cntlzw.', 'crand', 'crandc', 'crclr', 'creqv', 'crmove', 'crnand', 'crnor', 'crnot',
                        'cror', 'crorc', 'crset', 'crxor', 'dcba', 'dcbf', 'dcbi', 'dcbst', 'dcbt', 'dcbt', 'dcbt',
                        'dcbtst', 'dcbtst', 'dcbtst', 'dcbz', 'dcbz_l', 'dclz', 'divw', 'divw.', 'divwo', 'divwo.',
                        'divwu', 'divwu.', 'divwuo', 'divwuo.', 'eciwx', 'ecowx', 'eieio', 'eieio', 'eieio', 'eqv',
                        'eqv.', 'extsb', 'extsb.', 'extsh', 'extsh.', 'fabs', 'fabs.', 'fadd', 'fadd.', 'fadds',
                        'fadds.', 'fcmpo', 'fcmpu', 'fctiw', 'fctiw.', 'fctiwz', 'fctiwz.', 'fdiv', 'fdiv.', 'fdivs',
                        'fdivs.', 'fmadd', 'fmadd.', 'fmadds', 'fmadds.', 'fmr', 'fmr.', 'fmsub', 'fmsub.', 'fmsubs',
                        'fmsubs.', 'fmul', 'fmul.', 'fmuls', 'fmuls.', 'fnabs', 'fnabs.', 'fneg', 'fneg.', 'fnmadd',
                        'fnmadd.', 'fnmadds', 'fnmadds.', 'fnmsub', 'fnmsub.', 'fnmsubs', 'fnmsubs.', 'fres', 'fres',
                        'fres.', 'fres.', 'frsp', 'frsp.', 'frsqrte', 'frsqrte', 'frsqrte.', 'frsqrte.', 'fsel',
                        'fsel.', 'fsqrt', 'fsqrt.', 'fsqrts', 'fsqrts.', 'fsub', 'fsub.', 'fsubs', 'fsubs.', 'icbi',
                        'isync', 'la', 'lbz', 'lbzu', 'lbzux', 'lbzx', 'lfd', 'lfdu', 'lfdux', 'lfdx', 'lfs', 'lfsu',
                        'lfsux', 'lfsx', 'lha', 'lhau', 'lhaux', 'lhax', 'lhbrx', 'lhz', 'lhzu', 'lhzux', 'lhzx', 'li',
                        'lis', 'lmw', 'lswi', 'lswx', 'lwarx', 'lwbrx', 'lwsync', 'lwsync', 'lwz', 'lwzu', 'lwzux',
                        'lwzx', 'mcrf', 'mcrfs', 'mcrxr', 'mfbar', 'mfcmpa', 'mfcmpb', 'mfcmpc', 'mfcmpd', 'mfcmpe',
                        'mfcmpf', 'mfcmpg', 'mfcmph', 'mfcounta', 'mfcountb', 'mfcr', 'mfctr', 'mfdar', 'mfdbatl',
                        'mfdbatu', 'mfdc_adr', 'mfdc_cst', 'mfdc_dat', 'mfdec', 'mfdec', 'mfder', 'mfdpdr', 'mfdpir',
                        'mfdsisr', 'mfear', 'mffs', 'mffs.', 'mfibatl', 'mfibatu', 'mfic_adr', 'mfic_cst', 'mfic_dat',
                        'mficr', 'mfictc', 'mfictrl', 'mfimmr', 'mfl2cr', 'mflctrl1', 'mflctrl2', 'mflr', 'mfm_casid',
                        'mfm_tw', 'mfmd_ap', 'mfmd_ctr', 'mfmd_dbcam', 'mfmd_dbram0', 'mfmd_dbram1', 'mfmd_epn',
                        'mfmd_rpn', 'mfmd_twb', 'mfmd_twc', 'mfmi_ap', 'mfmi_ctr', 'mfmi_dbcam', 'mfmi_dbram0',
                        'mfmi_dbram1', 'mfmi_epn', 'mfmi_rpn', 'mfmi_twc', 'mfmmcr0', 'mfmmcr1', 'mfmsr', 'mfocrf',
                        'mfpmc1', 'mfpmc2', 'mfpmc3', 'mfpmc4', 'mfpvr', 'mfrtcl', 'mfrtcu', 'mfsdr1', 'mfsia',
                        'mfspr', 'mfsprg', 'mfsprg0', 'mfsprg1', 'mfsprg2', 'mfsprg3', 'mfsr', 'mfsrin', 'mfsrr0',
                        'mfsrr1', 'mftb', 'mftb', 'mftbl', 'mftbl', 'mftbu', 'mftbu', 'mfthrm1', 'mfthrm2', 'mfthrm3',
                        'mfummcr0', 'mfummcr1', 'mfupmc1', 'mfupmc2', 'mfupmc3', 'mfupmc4', 'mfusia', 'mfxer', 'mr',
                        'mr.', 'mtbar', 'mtcmpa', 'mtcmpb', 'mtcmpc', 'mtcmpd', 'mtcmpe', 'mtcmpf', 'mtcmpg', 'mtcmph',
                        'mtcounta', 'mtcountb', 'mtcr', 'mtcrf', 'mtctr', 'mtdar', 'mtdbatl', 'mtdbatu', 'mtdec',
                        'mtder', 'mtdsisr', 'mtear', 'mtfsb0', 'mtfsb0.', 'mtfsb1', 'mtfsb1.', 'mtfsf', 'mtfsf',
                        'mtfsf.', 'mtfsf.', 'mtfsfi', 'mtfsfi', 'mtfsfi.', 'mtfsfi.', 'mtibatl', 'mtibatu', 'mticr',
                        'mtictc', 'mtictrl', 'mtl2cr', 'mtlctrl1', 'mtlctrl2', 'mtlr', 'mtmmcr0', 'mtmmcr1', 'mtmsr',
                        'mtocrf', 'mtpmc1', 'mtpmc2', 'mtpmc3', 'mtpmc4', 'mtrtcl', 'mtrtcu', 'mtsdr1', 'mtsia',
                        'mtspr', 'mtsprg', 'mtsprg0', 'mtsprg1', 'mtsprg2', 'mtsprg3', 'mtsr', 'mtsrin', 'mtsrr0',
                        'mtsrr1', 'mttbl', 'mttbu', 'mtthrm1', 'mtthrm2', 'mtthrm3', 'mtummcr0', 'mtummcr1', 'mtupmc1',
                        'mtupmc2', 'mtupmc3', 'mtupmc4', 'mtusia', 'mtxer', 'mulhw', 'mulhw.', 'mulhwu', 'mulhwu.',
                        'mulli', 'mullw', 'mullw.', 'mullwo', 'mullwo.', 'nand', 'nand.', 'neg', 'neg.', 'nego',
                        'nego.', 'nop', 'nor', 'nor.', 'not', 'not.', 'or', 'or.', 'orc', 'orc.', 'ori', 'oris',
                        'ps_abs', 'ps_abs.', 'ps_add', 'ps_add.', 'ps_cmpo0', 'ps_cmpo1', 'ps_cmpu0', 'ps_cmpu1',
                        'ps_div', 'ps_div.', 'ps_madd', 'ps_madd.', 'ps_madds0', 'ps_madds0.', 'ps_madds1',
                        'ps_madds1.', 'ps_merge00', 'ps_merge00.', 'ps_merge01', 'ps_merge01.', 'ps_merge10',
                        'ps_merge10.', 'ps_merge11', 'ps_merge11.', 'ps_mr', 'ps_mr.', 'ps_msub', 'ps_msub.', 'ps_mul',
                        'ps_mul.', 'ps_muls0', 'ps_muls0.', 'ps_muls1', 'ps_muls1.', 'ps_nabs', 'ps_nabs.', 'ps_neg',
                        'ps_neg.', 'ps_nmadd', 'ps_nmadd.', 'ps_nmsub', 'ps_nmsub.', 'ps_res', 'ps_res.', 'ps_rsqrte',
                        'ps_rsqrte.', 'ps_sel', 'ps_sel.', 'ps_sub', 'ps_sub.', 'ps_sum0', 'ps_sum0.', 'ps_sum1',
                        'ps_sum1.', 'psq_l', 'psq_lu', 'psq_lux', 'psq_lx', 'psq_st', 'psq_stu', 'psq_stux', 'psq_stx',
                        'rfi', 'rlwimi', 'rlwimi.', 'rlwinm', 'rlwinm.', 'rlwnm', 'rlwnm.', 'rotlw', 'rotlw.',
                        'rotlwi', 'rotlwi.', 'sc', 'slw', 'slw.', 'slwi', 'slwi.', 'sraw', 'sraw.', 'srawi', 'srawi.',
                        'srw', 'srw.', 'srwi', 'srwi', 'srwi.', 'stb', 'stbu', 'stbux', 'stbx', 'stfd', 'stfdu',
                        'stfdux', 'stfdx', 'stfiwx', 'stfs', 'stfsu', 'stfsux', 'stfsx', 'sth', 'sthbrx', 'sthu',
                        'sthux', 'sthx', 'stmw', 'stswi', 'stswx', 'stw', 'stwbrx', 'stwcx.', 'stwu', 'stwux', 'stwx',
                        'sub', 'sub.', 'subc', 'subc.', 'subco', 'subco.', 'subf', 'subf.', 'subfc', 'subfc.',
                        'subfco', 'subfco.', 'subfe', 'subfe.', 'subfeo', 'subfeo.', 'subfic', 'subfme', 'subfme.',
                        'subfmeo', 'subfmeo.', 'subfo', 'subfo.', 'subfze', 'subfze.', 'subfzeo', 'subfzeo.', 'subi',
                        'subic', 'subic.', 'subis', 'subo', 'subo.', 'sync', 'sync', 'sync', 'tlbia', 'tlbie', 'tlbie',
                        'tlbie', 'tlbld', 'tlbli', 'tlbsync', 'trap', 'tw', 'tweq', 'tweqi', 'twge', 'twgei', 'twgt',
                        'twgti', 'twi', 'twle', 'twlei', 'twlge', 'twlgei', 'twlgt', 'twlgti', 'twlle', 'twllei',
                        'twllt', 'twllti', 'twlng', 'twlngi', 'twlnl', 'twlnli', 'twlt', 'twlti', 'twne', 'twnei',
                        'twng', 'twngi', 'twnl', 'twnli', 'xor', 'xor.', 'xori', 'xoris')
# list of assemble-able instructions in the -mgekko machine archetype

DOC_TAG_OUTDIR = ''
# DOC tags are used to automate formatting punkpc modules, but can be used with any input
# - leave blank if you want to disable tag parsing step
# - else, use the block comment tags /*## Header:   /*## Examples:  /*## Attributes:
#    to input comments and examples that document a module
DOC_DASH_WIDTH = 99
# dash length in characters for headers that start with '\n# ---' and end with ':\n'
# - if ':' can be replaced with at least 3 dashes without overflowing width, then dashes
#    will be added to the end of the header to visually separate block with a horizontal bar


# --- End of options ---


def get_path(path):
    # returns a path with optional working directory prefix

    p = path.strip().replace('\\', '/')
    split = p.split('..')
    if p.startswith(('.')):
        p = os.getcwd().replace('\\', '/')+ '/'
        p = p.rsplit('/', len(split))[0] + split[-1].lstrip('.')
    # fetch local dir by using the length of the split list to determine number of slashes deep to go back

    fp = p.rsplit('/', 1)

    if len(fp) > 1:  fe = fp[1].rsplit('.', 1)
    else: fe = []
    f = ''
    if len(fe) > 1:
        if fe[1].startswith(VALID_EXTENSIONS) and not fe[0].startswith(EXCLUDED_FILENAME_PREFIXES):
            f = fp[1]
            p = fp[0]
        else:
            f = ''
            p = ''
    # if path includes a file, then return it separately from path
    # - if file is not a valid extension, file will remain blank
    sep = ''
    if f: sep = '/'
    return p, f, p + sep + f


def get_paths(paths):
    # only returns valid files and directories
    return [p for p in [get_path(x) for x in paths] if p[0] != '']


def check_for_overwrites(a, b):
    # returns list of file names from inputs that match names in output
    return [path for path in b for qpath in a if path[1] == qpath.rsplit("/", 1)[-1]]


def check_for_duplicates(l):
    # returns a list of non-unique filenames from all inputs
    duplicates = []
    for path in l:
        b = False
        for qpath in l:
            if path[1] == qpath[1]:
                if not b:
                    b = True
                else:
                    duplicates.append(path)
                    l.remove(path)
    return duplicates


def duplicate_prompt():
    # - we summarize names list if over 32 conflicts are present, to avoid crowding dialogue
    msg = True
    if SHOW_PROMPTS:
        msg = "Duplicate files detected:\n"
        msg += duplicates[0][1] + "  "
        if len(overwrites) > 32:
            for filename in duplicates[1:31]:
                msg += filename[1] + ", "
            msg += "and " + str(len(duplicates) - 32) + " other files "
        else:
            for filename in duplicates[1:]:
                msg += filename[1] + ", "
        if len(duplicates) > 1:
            msg += "has "
        else:
            msg += "have "
        msg += "been given from multiple directories.\n"
        msg += "\n\nContinue while ignoring these conflicts?"
        msg = messagebox.askokcancel(msgname, msg,)
    return msg


def overwrite_prompt():
    # - we summarize names list if over 32 conflicts are present, to avoid crowding dialogue
    msg = True
    if SHOW_PROMPTS:
        msg = "Output files detected:\n"
        msg += overwrites[0][1] + "  "
        if len(overwrites) > 32:
            for filename in overwrites[1:31]:
                msg += filename[1] + ", "
            msg += "and " + str(len(overwrites) - 32) + " other files "
        else:
            for filename in overwrites[1:]:
                msg += filename[1] + ", "
        if len(overwrites) > 1:
            msg += "already exist in:\n" + OUTPUT_DIR
        else:
            msg += "already exists in:\n" + OUTPUT_DIR
        warnings = [w for w in overwrites if w[0] == OUTPUT_DIR]
        if warnings:
            msg += "\n\nWARNING: This includes " + str(len(warnings))
            if len(warnings) > 1:
                msg += " input files"
            else:
                msg += " input file"
            msg += "; which will be overwritten."
        else:
            msg += "\n\nInput file(s) will not be overwritten."
        msg += "\n\nProceed with overwrite?"
        msg = messagebox.askokcancel(msgname, msg)
    return msg


def formatted_prompt(l):
    if SHOW_PROMPTS:
        if not l:  msg = messagebox.showerror(msgname, 'No files were written.')
        else:
            msg = str(l)
            if l > 1:
                msg += " files have"
            else:
                msg += " file has"
            msg += " been formatted and written to:\n\n" + OUTPUT_DIR
            messagebox.showinfo(msgname, msg)
    return


def no_files_prompt():
    if SHOW_PROMPTS:
        msg = 'Only '
        if len(VALID_EXTENSIONS) > 1:
            for ext in VALID_EXTENSIONS[:-1]:  msg += '*.' + ext + ',  '
        msg += 'and  *.' + VALID_EXTENSIONS[-1] + \
               ' files are accepted.\nYou may edit valid extensions and create a default input directory in the options provided in the script file header'
        messagebox.showerror(msgname, msg)
    return


def cmd_arg_handler(va):
    global SHOW_PROMPTS, ENABLE_NEWLINE_KEYWORDS, ENABLE_NEWLINE_PREFIXES, ENABLE_INDENTATION, CONCAT_NL_OUTDENT, \
        ENDLINE_SEMICOL, INSTRUCTION_NEWLINES, OUTPUT_DIR, INPUT_DIR, REFLOW_WIDTH, INDENT_PREFIXES, OUTDENT_PREFIXES, \
        FORCE_THIS_NEWLINE_PREFIXES, FORCE_NEXT_NEWLINE_PREFIXES, VALID_EXTENSIONS, EXCLUDED_FILENAME_PREFIXES, \
        COMMA, SEMICOL, INDENT, ARGDEF_WS, ARGDEF_COMMA, ARGDEF_SEMICOL, DOC_TAG_OUTDIR
    if va:
        a = va[0].lower()  # a = arg
        if a.startswith(('-', '+')):
            b = False      # b = bool
            for c in a:    # c = char
                if c == '-':
                    b = False
                elif c == '+':
                    b = True
                elif c == 's':
                    SHOW_PROMPTS = b
                elif c == 'k':
                    ENABLE_NEWLINE_KEYWORDS = b
                elif c == 'p':
                    ENABLE_NEWLINE_PREFIXES = b
                elif c == 'i':
                    ENABLE_INDENTATION = b
                elif c == 'c':
                    CONCAT_NL_OUTDENT = b
                elif c == 'e':
                    ENDLINE_SEMICOL = b
                elif c == 'm':
                    INSTRUCTION_NEWLINES = b
            va = cmd_arg_handler(va[1:])
        else:
            a=va[0].split(':', 1)
            a[0] = a[0].lower()
            if a[0] =='in':
                INPUT_DIR = a[1].lstrip()
                va = cmd_arg_handler(va[1:])
            elif a[0] =='out':
                OUTPUT_DIR = a[1].lstrip()
                va = cmd_arg_handler(va[1:])
            elif a[0] == 'width':
                REFLOW_WIDTH = int(a[1].lstrip())
                va = cmd_arg_handler(va[1:])
            elif a[0] == 'indent':
                INDENT_PREFIXES = tuple(s.lstrip() for s in a[1].split(','))
                va = cmd_arg_handler(va[1:])
            elif a[0] == 'outdent':
                OUTDENT_PREFIXES = tuple(s.lstrip() for s in a[1].split(','))
                va = cmd_arg_handler(va[1:])
            elif a[0] == 'thisnl':
                FORCE_THIS_NEWLINE_PREFIXES = tuple(s.lstrip() for s in a[1].split(','))
                va = cmd_arg_handler(va[1:])
            elif a[0] == 'nextnl':
                FORCE_NEXT_NEWLINE_PREFIXES = tuple(s.lstrip() for s in a[1].split(','))
                va = cmd_arg_handler(va[1:])
            elif a[0] == 'ext':
                VALID_EXTENSIONS = tuple(s.lstrip() for s in a[1].split(','))
                va = cmd_arg_handler(va[1:])
            elif a[0] == 'exclude':
                EXCLUDED_FILENAME_PREFIXES = tuple(s.lstrip() for s in a[1].split(','))
                va = cmd_arg_handler(va[1:])
            elif a[0] =='comma_ws':
                COMMA = a[1]
                va = cmd_arg_handler(va[1:])
            elif a[0] =='semicol_ws':
                SEMICOL = a[1]
                va = cmd_arg_handler(va[1:])
            elif a[0] =='indent_ws':
                INDENT = a[1]
                va = cmd_arg_handler(va[1:])
            elif a[0] =='argdef_ws':
                ARGDEF_WS = a[1]
                va = cmd_arg_handler(va[1:])
            elif a[0] =='doctag':
                DOC_TAG_OUTDIR = a[1]
                va = cmd_arg_handler(va[1:])
            else:
                va = [a.replace('\\', '/') for a in va]

    return va


# --- Script:

msgname = "GAS Formatter"
tkdefault = tkinter.Tk()
tkdefault.withdraw()
file = ''
overwrites = []
overwrite = ''
write = False
output = ''
input_paths = cmd_arg_handler([x for x in sys.argv[1:]])
SEMICOL = ';' + SEMICOL
COMMA = ',' + COMMA
ARGDEF_COMMA = ',' + ARGDEF_WS
ARGDEF_SEMICOL = ';' + ARGDEF_WS
sc_len = len(SEMICOL)
in_len = len(INDENT)
ar_len = len(ARGDEF_COMMA)
if not OUTPUT_DIR:  OUTPUT_DIR = '.'
if DOC_TAG_OUTDIR:  DOC_TAG_OUTDIR = get_path(DOC_TAG_OUTDIR)[0]
OUTPUT_DIR = get_path(OUTPUT_DIR)[0]
if INPUT_DIR:  input_paths.append(get_path(INPUT_DIR)[2])
fpaths = get_paths(input_paths)
# fpaths keeps a path and a file name separately as [dir, file]
# - if no file is present, then it is not a valid file extension


if REFLOW_WIDTH < 0:  REFLOW_WIDTH = 0x7FFFFFF
# virtually infinite width for negative number settings

for path in fpaths:
    if path[1] == '':
        paths = []
        try:
            paths = get_paths([fp.path for fp in os.scandir(path[0])])
        except:  paths = []
        finally:
            if paths:  fpaths.extend([fp for fp in paths if fp[1] != ''])
# attempt to explore no-extension inputs to check for directories for other files
# - if it is a directory, then valid files will be accepted from the directory

files = [fp for fp in fpaths if fp[1] != '']
if files:  # if at least one valid file was found...
    overwrites = check_for_overwrites([p.path.replace('\\', '/') for p in os.scandir(OUTPUT_DIR)], files)
    # overwrites[] will keep a list of local files that will be overwritten on write

    duplicates = check_for_duplicates(files)
    duplicates_check = True
    if duplicates:
        for f in files:
            for d in duplicates:
                if f[1] == d[1]:  files.remove(f)
        duplicates_check = duplicate_prompt()

    if overwrites and duplicates_check:  # if at least one conflict was found...
        write = overwrite_prompt()
    else:
        write = duplicates_check
    if write:
        for filename in files:
            with open(filename[2], 'r', newline=None) as file:
                str_read = file.read().replace('\t', ' ')
            # get text from file

            # --- DOC TAG PARSE:
            # if documentation tags have been enabled, parse them before trimming comments
            # - these are used to extract documentation out of punkpc *.s class module files
            if DOC_TAG_OUTDIR:
                doc_output = ''
                doc_sub = ''
                try:  # using try blocks with index of specific tags
                    doc_sub = str_read.index('/*## Header:') + 12
                    doc_sub = str_read[doc_sub : str_read.index('*/', doc_sub)].rstrip('#') + '\n'
                except:  doc_sub = ''
                doc_output += doc_sub.rstrip('\n').rstrip() + '\n\n\n'
                # capture header

                try:
                    doc_sub = str_read.index('/*## Examples:') + 14
                    doc_sub = str_read[doc_sub : str_read.index('*/', doc_sub)].rstrip('#') + '\n'
                except:  doc_sub = ''
                if doc_sub:
                    ex_head = '# --- Example use of the ' + filename[1].split('.')[0] + ' module:\n\n'
                    doc_sub = ex_head + doc_sub.strip('\n')
                doc_output += doc_sub.rstrip('\n').rstrip() + '\n\n\n'
                # capture examples

                try:
                    doc_sub = str_read.index('/*## Attributes:') + 16
                    doc_sub = str_read[doc_sub : str_read.index('*/', doc_sub)].rstrip('#') + '\n'
                except:  doc_sub = ''
                # capture attributes, and reformat them by searching for # --- headers:
                if doc_sub:
                    split = doc_sub.split('# ---')
                    if len(split) > 1:
                        doc_sub = ''
                        for s in split[0:-2]:
                            if not s.endswith("\n\n"):
                                s = s.rstrip('\n').rstrip()
                                if s.count('\n'):  doc_sub += s + '\n\n# ---'
                                else:  doc_sub += s + '\n# ---'
                            else:  doc_sub += s + '# ---'
                        doc_sub = doc_sub.lstrip('\n') + split[-1]
                        # rebuild attribute headers that start with # --- to enforce a blank line prefix

                    doc_sub = '# --- Module attributes:\n' + doc_sub.strip('\n')
                doc_output += doc_sub
                # doc output has been captured

                # we create a syntax that makes a header line into a horizontal bar with width 'length
                split = doc_output.splitlines(True)
                doc_output = ''
                for l in split:
                    if l.count('# ---'):
                        idx = l.index('# ---')
                        if l.count(' ---\n'):
                            sub = l[idx:l.index(' ---\n')] + ' '
                            dash_len = DOC_DASH_WIDTH - len(sub)
                            if dash_len >= 3:
                                l = sub
                                for i in range(dash_len): l += '-'
                                l += '\n'
                                # if 3 or more dashes fit in the width range, then line is reformatted

                    doc_output += l
                    split = filename[1].split('.')
                    f = DOC_TAG_OUTDIR + '/' + split[0] + '_doc.' + split[1]
                    with open(f, 'w', newline=None) as file:
                        file.write(doc_output.lstrip('\n') + '\n\n')

            # --- TRIM PARSE:
            # first pass trims things according to syntax rules for block comments, line comments, and strings

            # character case bools:
            bc = False  # block comment trim
            lc = False  # line comment trim
            qs = False  # quoted string preservation
            sc = False  # semicolon whitespace trim
            cm = False  # comma whitespace trim
            ws = False  # excess whitespace trim
            line = ''  # line buffer
            lines = []  # line list
            for c in str_read:
                # character case logic map:

                if not bc and lc:  # if unprotected line comment
                    qs = False
                    if c == '\n':
                        lc = False
                elif bc:  # if block comment...
                    if bc == 1:  # and checking for second enter block char
                        if c == '*':
                            bc = 2
                            qs = False
                        else:
                            bc = False
                            line += '/'
                    elif bc == 2:  # and checking for first exit block char
                        if c == '*':
                            bc = 3
                    elif bc == 3:  # and checking for second exit block char
                        if c == '/':
                            bc = False
                            continue
                        else:
                            bc = 2
                else:  # if not in comment state
                    if c == '#':
                        lc = True
                    elif c == '/':
                        bc = 1
                if not (bc or lc):  # if not entering comment state
                    if c == '\n':
                        c = ';'  # convert newlines to semicolons
                        qs = False  # but do not allow newlines in strings
                    if qs:
                        line += c  # if checking for exit quote
                        if c == '"':
                            qs = False
                    else:  # if not in any state, or just checking for whitespace...
                        if sc or cm or ws:  # trim unnecessary whitespace
                            if c.isspace():
                                continue
                            else:
                                sc = False
                                cm = False
                                ws = False
                        if c == ';':
                            sc = True  # split semicolons into separate line, for reflow step
                            line = line.rstrip()
                            if line != '':
                                lines.append(line)
                            line = ''
                            continue
                        elif c == '"':
                            qs = True  # start quotes
                        elif c.isspace():
                            ws = True  # trim excess whitespace
                        elif c == ',':
                            cm = True  # trim comma whitespace
                            line += COMMA
                            continue
                        line += c  # concat char
            if line != '':
                lines.append(line)

            # --- REFLOW PARSE:
            # second pass reflows trimmed portions remaining from first pass

            llen = 0  # line length
            lbuf = ''  # line buffer
            output = ''  # output buffer
            nl_next = False
            nl_this = False
            nl_kw = False
            indent_ctr = 0
            indenting = False
            outdenting = False
            end_sc = ENDLINE_SEMICOL and not ENDLINE_SEMICOL_ONLY_OUTDENTS
            for l in lines:
                indent_ctr += indenting  # update indents on next iteration (before flag updates)
                argdef = USE_ARGDEF_WS and indenting
                indenting = False
                # make use of indenting flag from last iteration, before resetting flag

                nl_conc = False
                end_sc = ENDLINE_SEMICOL and (not ENDLINE_SEMICOL_ONLY_OUTDENTS or outdenting)
                if l.startswith(INDENT_PREFIXES):
                    if outdenting and nl_this and CONCAT_NL_OUTDENT:
                        nl_conc = True
                    # concat option may make better use of whitespace in output
                    indenting = True
                    if USE_ARGDEF_WS:
                        split = [s.strip(' ') for s in l.split(',')]
                        l = split[0]
                        if len(split) > 1:
                            for arg in split[1:]:
                                l += ARGDEF_COMMA + arg
                    # use different whitespace for commas in argument definitions for blocks of code

                if l.startswith(OUTDENT_PREFIXES):
                    outdenting = True
                    indent_ctr -= 1  # update outdents immediately
                    if nl_this and CONCAT_NL_OUTDENT:
                        nl_conc = True
                else:
                    outdenting = False

                nl_this = nl_next or nl_kw
                if ENABLE_NEWLINE_PREFIXES:
                    nl_this |= l.startswith(FORCE_THIS_NEWLINE_PREFIXES)
                    nl_next = l.startswith(FORCE_NEXT_NEWLINE_PREFIXES)
                nl_kw = not not [kw for kw in FORCE_NEXT_NEWLINE_KEYWORDS if l.count(kw)] and ENABLE_NEWLINE_KEYWORDS
                if INSTRUCTION_NEWLINES:
                    nl_this |= l.split(' ', 1)[0] in INSTRUCTION_KEYWORDS
                # apply newline keyword/prefix logic

                if not ENABLE_INDENTATION:  indent_ctr = 0
                width = REFLOW_WIDTH - (indent_ctr * in_len)
                length = len(l)  # this subline's length
                overflow = llen + sc_len + length + end_sc > width
                if (overflow and llen) or (nl_this and not nl_conc):
                    # if reflow width overflow and not empty -- or if newline is being forced

                    if end_sc:
                        output += lbuf + ';\n'
                    else:
                        output += lbuf + '\n'  # apply newline
                    for i in range(indent_ctr):  l = INDENT + l
                    lbuf = l
                    llen = len(lbuf)
                    continue
                    # apply indents to buffer and continue

                elif not (lbuf == '' or lbuf.isspace()):  # if not applying newline
                    if argdef:
                        llen += ar_len
                        lbuf += ARGDEF_SEMICOL
                    else:
                        llen += sc_len
                        lbuf += SEMICOL
                llen += length  # concatenate this to buffer using a semicolon, if necessary
                lbuf += l
            if output.startswith('\n'):  output = output[1:]  # remove leading newline, if present
            if end_sc:  lbuf += ';'
            output += lbuf + '\n\n'  # always end document with a blank line

            # --- OUTPUT FILE:
            f = OUTPUT_DIR + '/' + filename[1]
            with open(f, 'w', newline=None) as file:
                file.write(output)
            # print(output)
        formatted_prompt(len(files))
else:
    no_files_prompt()
