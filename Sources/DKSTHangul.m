#import "DKSTHangul.h"
#import <Cocoa/Cocoa.h>

// Unicode Jamo Constants
#define CHO_BASE  0x1100
#define JUNG_BASE 0x1161
#define JONG_BASE 0x11A7 

@interface DKSTHangul () {
    unichar _cho;
    unichar _jung;
    unichar _jong;
    NSMutableString *_buffer;
    NSMutableString *_completed;
}
@end

@implementation DKSTHangul

- (instancetype)init {
    self = [super init];
    if (self) {
        _buffer = [[NSMutableString alloc] init];
        _completed = [[NSMutableString alloc] init];
        [self reset];
    }
    return self;
}

- (void)dealloc {
    [_buffer release];
    [_completed release];
    [super dealloc];
}

- (void)reset {
    _cho = 0;
    _jung = 0;
    _jong = 0;
    [_buffer setString:@""];
    [_completed setString:@""];
}

- (NSString *)composedString {
    if (_cho == 0 && _jung == 0 && _jong == 0) return @"";
    return [NSString stringWithFormat:@"%C", [self currentSyllable]];
}

- (NSString *)commitString {
    NSString *res = [NSString stringWithString:_completed];
    [_completed setString:@""];
    return res;
}

// Check types
- (BOOL)isCho:(unichar)c { return c >= 0x1100 && c <= 0x1112; }
- (BOOL)isJung:(unichar)c { return c >= 0x1161 && c <= 0x1175; }
- (BOOL)isJong:(unichar)c { return (c >= 0x11A8 && c <= 0x11C2); }

- (unichar)mapFromChar:(unichar)c {
    if (self.keyboardLayout == DKSTHangulKeyboardLayoutSebeolsik390) {
        return [self mapSebeolsik390FromChar:c];
    }
    if (self.keyboardLayout == DKSTHangulKeyboardLayoutSebeolsikFinal) {
        return [self mapSebeolsikFinalFromChar:c];
    }

    switch(c) {
        case 'q': return 0x1107; case 'Q': return 0x1108; // ㅂ, ㅃ
        case 'w': return 0x110c; case 'W': return 0x110d; // ㅈ, ㅉ
        case 'e': return 0x1103; case 'E': return 0x1104; // ㄷ, ㄸ
        case 'r': return 0x1100; case 'R': return 0x1101; // ㄱ, ㄲ
        case 't': return 0x1109; case 'T': return 0x110a; // ㅅ, ㅆ
        case 'y': return 0x116d; case 'Y': return 0x116d; // ㅛ
        case 'u': return 0x1167; case 'U': return 0x1167; // ㅕ
        case 'i': return 0x1163; case 'I': return 0x1163; // ㅑ
        case 'o': return 0x1162; case 'O': return 0x1164; // o=ㅐ, O=ㅒ
        case 'p': return 0x1166; case 'P': return 0x1168; // p=ㅔ, P=ㅖ
        
        case 'a': return 0x1106; case 'A': return 0x1106; // ㅁ
        case 's': return 0x1102; case 'S': return 0x1102; // ㄴ
        case 'd': return 0x110b; case 'D': return 0x110b; // ㅇ
        case 'f': return 0x1105; case 'F': return 0x1105; // ㄹ
        case 'g': return 0x1112; case 'G': return 0x1112; // ㅎ
        case 'h': return 0x1169; case 'H': return 0x1169; // ㅗ
        case 'j': return 0x1165; case 'J': return 0x1165; // ㅓ
        case 'k': return 0x1161; case 'K': return 0x1161; // ㅏ
        case 'l': return 0x1175; case 'L': return 0x1175; // ㅣ
        
        case 'z': return 0x110f; case 'Z': return 0x110f; // ㅋ
        case 'x': return 0x1110; case 'X': return 0x1110; // ㅌ
        case 'c': return 0x110e; case 'C': return 0x110e; // ㅊ
        case 'v': return 0x1111; case 'V': return 0x1111; // ㅍ
        case 'b': return 0x1172; case 'B': return 0x1172; // ㅠ
        case 'n': return 0x116e; case 'N': return 0x116e; // ㅜ
        case 'm': return 0x1173; case 'M': return 0x1173; // ㅡ
        default: return 0;
    }
}

- (unichar)mapSebeolsik390FromChar:(unichar)c {
    switch(c) {
        // Sebeolsik 390: lower-case entries are unshifted, upper-case entries are shifted.
        case 'q': return 0x11BA; case 'Q': return 0x11C1; // 종성 ㅅ, ㅍ
        case 'w': return 0x11AF; case 'W': return 0x11C0; // 종성 ㄹ, ㅌ
        case 'e': return 0x1167; case 'E': return 0x11BF; // ㅕ, 종성 ㅋ
        case 'r': return 0x1162; case 'R': return 0x1164; // ㅐ, ㅒ
        case 't': return 0x1165; case 'T': return ';';    // ㅓ, ;

        case 'a': return 0x11BC; case 'A': return 0x11AE; // 종성 ㅇ, ㄷ
        case 's': return 0x11AB; case 'S': return 0x11AD; // 종성 ㄴ, ㄶ
        case 'd': return 0x1175; case 'D': return 0x11B0; // ㅣ, 종성 ㄺ
        case 'f': return 0x1161; case 'F': return 0x11A9; // ㅏ, 종성 ㄲ
        case 'g': return 0x1173; case 'G': return '/';    // ㅡ, /

        case 'z': return 0x11B7; case 'Z': return 0x11BE; // 종성 ㅁ, ㅊ
        case 'x': return 0x11A8; case 'X': return 0x11B9; // 종성 ㄱ, ㅄ
        case 'c': return 0x1166; case 'C': return 0x11B2; // ㅔ, 종성 ㄼ
        case 'v': return 0x1169; case 'V': return 0x11B6; // ㅗ, 종성 ㅀ
        case 'b': return 0x116E; case 'B': return '!';    // ㅜ, !

        case 'y': return 0x1105; case 'Y': return '<';    // 초성 ㄹ, <
        case 'u': return 0x1103; case 'U': return '7';    // 초성 ㄷ, 7
        case 'i': return 0x1106; case 'I': return '8';    // 초성 ㅁ, 8
        case 'o': return 0x110E; case 'O': return '9';    // 초성 ㅊ, 9
        case 'p': return 0x1111; case 'P': return '>';    // 초성 ㅍ, >
        case 'h': return 0x1102; case 'H': return '\'';   // 초성 ㄴ, '
        case 'j': return 0x110B; case 'J': return '4';    // 초성 ㅇ, 4
        case 'k': return 0x1100; case 'K': return '5';    // 초성 ㄱ, 5
        case 'l': return 0x110C; case 'L': return '6';    // 초성 ㅈ, 6
        case ';': return 0x1107; case ':': return ':';    // 초성 ㅂ, :
        case '\'': return 0x1110; case '"': return '"';   // 초성 ㅌ, "
        case 'n': return 0x1109; case 'N': return '0';    // 초성 ㅅ, 0
        case 'm': return 0x1112; case 'M': return '1';    // 초성 ㅎ, 1

        case '1': return 0x11C2; case '!': return 0x11BD; // 종성 ㅎ, ㅈ
        case '2': return 0x11BB; case '@': return '@';    // 종성 ㅆ, @
        case '3': return 0x11B8; case '#': return '#';    // 종성 ㅂ, #
        case '4': return 0x116D; case '$': return '$';    // ㅛ, $
        case '5': return 0x1172; case '%': return '%';    // ㅠ, %
        case '6': return 0x1163; case '^': return '^';    // ㅑ, ^
        case '7': return 0x1168; case '&': return '&';    // ㅖ, &
        case '8': return 0x1174; case '*': return '*';    // ㅢ, *
        case '9': return 0x116E; case '(': return '(';    // ㅜ, (
        case '0': return 0x110F; case ')': return ')';    // 초성 ㅋ, )
        case '/': return 0x1169; case '?': return '?';    // ㅗ, ?
        case ',': return ',';    case '<': return '2';
        case '.': return '.';    case '>': return '3';
        default: return 0;
    }
}

- (unichar)mapSebeolsikFinalFromChar:(unichar)c {
    switch(c) {
        // Sebeolsik Final: lower-case entries are unshifted, upper-case entries are shifted.
        case 'q': return 0x11BA; case 'Q': return 0x11C1; // 종성 ㅅ, ㅍ
        case 'w': return 0x11AF; case 'W': return 0x11C0; // 종성 ㄹ, ㅌ
        case 'e': return 0x1167; case 'E': return 0x11AC; // ㅕ, 종성 ㄵ
        case 'r': return 0x1162; case 'R': return 0x11B6; // ㅐ, 종성 ㅀ
        case 't': return 0x1165; case 'T': return 0x11B3; // ㅓ, 종성 ㄽ

        case 'a': return 0x11BC; case 'A': return 0x11AE; // 종성 ㅇ, ㄷ
        case 's': return 0x11AB; case 'S': return 0x11AD; // 종성 ㄴ, ㄶ
        case 'd': return 0x1175; case 'D': return 0x11B2; // ㅣ, 종성 ㄼ
        case 'f': return 0x1161; case 'F': return 0x11B1; // ㅏ, 종성 ㄻ
        case 'g': return 0x1173; case 'G': return 0x1164; // ㅡ, ㅒ

        case 'z': return 0x11B7; case 'Z': return 0x11BE; // 종성 ㅁ, ㅊ
        case 'x': return 0x11A8; case 'X': return 0x11B9; // 종성 ㄱ, ㅄ
        case 'c': return 0x1166; case 'C': return 0x11BF; // ㅔ, 종성 ㅋ
        case 'v': return 0x1169; case 'V': return 0x11AA; // ㅗ, 종성 ㄳ
        case 'b': return 0x116E; case 'B': return '?';    // ㅜ, ?

        case 'y': return 0x1105; case 'Y': return '5';    // 초성 ㄹ, 5
        case 'u': return 0x1103; case 'U': return '6';    // 초성 ㄷ, 6
        case 'i': return 0x1106; case 'I': return '7';    // 초성 ㅁ, 7
        case 'o': return 0x110E; case 'O': return '8';    // 초성 ㅊ, 8
        case 'p': return 0x1111; case 'P': return '9';    // 초성 ㅍ, 9
        case 'h': return 0x1102; case 'H': return '0';    // 초성 ㄴ, 0
        case 'j': return 0x110B; case 'J': return '1';    // 초성 ㅇ, 1
        case 'k': return 0x1100; case 'K': return '2';    // 초성 ㄱ, 2
        case 'l': return 0x110C; case 'L': return '3';    // 초성 ㅈ, 3
        case ';': return 0x1107; case ':': return '4';    // 초성 ㅂ, 4
        case '\'': return 0x1110; case '"': return 0x00B7; // 초성 ㅌ, ·
        case 'n': return 0x1109; case 'N': return '-';    // 초성 ㅅ, -
        case 'm': return 0x1112; case 'M': return '"';    // 초성 ㅎ, "

        case '1': return 0x11C2; case '!': return 0x11A9; // 종성 ㅎ, ㄲ
        case '2': return 0x11BB; case '@': return 0x11B0; // 종성 ㅆ, ㄺ
        case '3': return 0x11B8; case '#': return 0x11BD; // 종성 ㅂ, ㅈ
        case '4': return 0x116D; case '$': return 0x11B5; // ㅛ, 종성 ㄿ
        case '5': return 0x1172; case '%': return 0x11B4; // ㅠ, 종성 ㄾ
        case '6': return 0x1163; case '^': return '=';    // ㅑ, =
        case '7': return 0x1168; case '&': return 0x201C; // ㅖ, “
        case '8': return 0x1174; case '*': return 0x201D; // ㅢ, ”
        case '9': return 0x116E; case '(': return '\'';   // ㅜ, '
        case '0': return 0x110F; case ')': return '~';    // 초성 ㅋ, ~
        case '`': return '*';    case '~': return 0x203B; // *, ※
        case '-': return ')';    case '_': return ';';
        case '=': return '>';    case '+': return '+';
        case '[': return '(';    case '{': return '%';
        case ']': return '<';    case '}': return '/';
        case '\\': return ':';   case '|': return '\\';
        case '/': return 0x1169; case '?': return '!';    // ㅗ, !
        case ',': return ',';    case '<': return ',';
        case '.': return '.';    case '>': return '.';
        default: return 0;
    }
}

- (unichar)currentSyllable {
    if (_cho == 0 && _jung == 0 && _jong == 0) return 0;
    
    // Independent Jamo
    if (_cho && !_jung && !_jong) return [self compatibilityJamo:_cho];
    if (!_cho && _jung && !_jong) return [self compatibilityJamo:_jung];
    if (!_cho && !_jung && _jong) return [self compatibilityJamo:_jong];
    
    // Combined
    int choIdx = -1;
    if (_cho) choIdx = [self choIndex:_cho];
    
    int jungIdx = -1;
    if (_jung) jungIdx = [self jungIndex:_jung];
    
    int jongIdx = 0;
    if (_jong) jongIdx = [self jongIndex:_jong];
    
    if (choIdx != -1 && jungIdx != -1) {
        return 0xAC00 + (choIdx * 21 * 28) + (jungIdx * 28) + jongIdx;
    }
    
    // Jung Only? (Moa-jjiki transitional state)
    // If we have Jung but no Cho, return Compatible Jung
    if (jungIdx != -1 && choIdx == -1) {
        return [self compatibilityJamo:_jung];
    }
    
    return 0;
}

- (unichar)compatibilityJamo:(unichar)u {
    // Basic mapping for display of singular Jamo
    if (u >= 0x1100 && u <= 0x1112) {
        // Map Choseong to Compatibility
        const unichar map[] = {
            0x3131, 0x3132, 0x3134, 0x3137, 0x3138, 0x3139, 0x3141, 0x3142, 0x3143,
            0x3145, 0x3146, 0x3147, 0x3148, 0x3149, 0x314A, 0x314B, 0x314C, 0x314D, 0x314E
        };
        return map[u - 0x1100];
    }
    if (u >= 0x1161 && u <= 0x1175) {
        // Map Jungseong
        const unichar map[] = {
            0x314F, 0x3150, 0x3151, 0x3152, 0x3153, 0x3154, 0x3155, 0x3156, 0x3157,
            0x3158, 0x3159, 0x315A, 0x315B, 0x315C, 0x315D, 0x315E, 0x315F, 0x3160,
            0x3161, 0x3162, 0x3163
        };
        return map[u - 0x1161];
    }
    if (u >= 0x11A8 && u <= 0x11C2) {
        return [self compatibilityJamoForJong:u];
    }
    return u;
}

- (unichar)compatibilityJamoForJong:(unichar)u {
    switch (u) {
        case 0x11A8: return 0x3131; // ㄱ
        case 0x11A9: return 0x3132; // ㄲ
        case 0x11AA: return 0x3133; // ㄳ
        case 0x11AB: return 0x3134; // ㄴ
        case 0x11AC: return 0x3135; // ㄵ
        case 0x11AD: return 0x3136; // ㄶ
        case 0x11AE: return 0x3137; // ㄷ
        case 0x11AF: return 0x3139; // ㄹ
        case 0x11B0: return 0x313A; // ㄺ
        case 0x11B1: return 0x313B; // ㄻ
        case 0x11B2: return 0x313C; // ㄼ
        case 0x11B3: return 0x313D; // ㄽ
        case 0x11B4: return 0x313E; // ㄾ
        case 0x11B5: return 0x313F; // ㄿ
        case 0x11B6: return 0x3140; // ㅀ
        case 0x11B7: return 0x3141; // ㅁ
        case 0x11B8: return 0x3142; // ㅂ
        case 0x11B9: return 0x3144; // ㅄ
        case 0x11BA: return 0x3145; // ㅅ
        case 0x11BB: return 0x3146; // ㅆ
        case 0x11BC: return 0x3147; // ㅇ
        case 0x11BD: return 0x3148; // ㅈ
        case 0x11BE: return 0x314A; // ㅊ
        case 0x11BF: return 0x314B; // ㅋ
        case 0x11C0: return 0x314C; // ㅌ
        case 0x11C1: return 0x314D; // ㅍ
        case 0x11C2: return 0x314E; // ㅎ
        default: return u;
    }
}

- (int)choIndex:(unichar)c {
    if (c >= 0x1100 && c <= 0x1112) return c - 0x1100;
    return -1;
}

- (int)jungIndex:(unichar)c {
    if (c >= 0x1161 && c <= 0x1175) return c - 0x1161;
    return -1;
}

- (int)jongIndex:(unichar)c {
    if (c >= 0x11A8 && c <= 0x11C2) return c - 0x11A8 + 1;
    return 0;
}

- (BOOL)backspace {
    // 1. If empty, return NO
    if (_cho == 0 && _jung == 0 && _jong == 0) return NO;
    
    // Check Full Delete Option
    if (self.fullCharacterDelete) {
        _cho = 0;
        _jung = 0;
        _jong = 0;
        return YES;
    }
    
    // 2. Jongseong
    if (_jong != 0) {
        unichar j1 = 0, j2 = 0;
        [self splitJong:_jong first:&j1 second:&j2];
        if (j2 != 0) {
            // Was compound (e.g. ㅀ), revert to single (ㄹ)
            _jong = j1;
        } else {
            // Was single, remove it.
            _jong = 0;
        }
        return YES;
    }
    
    // 3. Jungseong
    if (_jung != 0) {
        // Check for compound Jung (e.g. ㅘ -> ㅗ)
        unichar j1 = 0, j2 = 0;
        [self splitJung:_jung first:&j1 second:&j2];
        if (j2 != 0) {
            _jung = j1;
        } else {
            _jung = 0;
        }
        return YES;
    }
    
    // 4. Choseong
    if (_cho != 0) {
        _cho = 0;
        return YES;
    }
    
    return NO;
}

- (BOOL)processCode:(NSInteger)keyCode modifiers:(NSUInteger)flags
{
    unichar input = [self asciiFromKeyCode:keyCode modifiers:flags];
    if (input == 0) return NO;
    
    unichar hangul = [self mapFromChar:input];
    
    if (hangul == 0) {
        if (_cho || _jung || _jong) {
            [_completed appendFormat:@"%C", [self currentSyllable]];
            _cho = 0; _jung = 0; _jong = 0;
        }
        return NO;
    }
    
    if (![self isCho:hangul] && ![self isJong:hangul] && ![self isJung:hangul]) {
        if (_cho || _jung || _jong) {
            [_completed appendFormat:@"%C", [self currentSyllable]];
            _cho = 0; _jung = 0; _jong = 0;
        }
        [_completed appendFormat:@"%C", hangul];
        return YES;
    }

    if ([self isCho:hangul]) {
        if (_jung == 0) {
             // State: Cho only or Empty
             if (_cho == 0) { _cho = hangul; }
             else { 
                 unichar compoundCho = [self combineCho:_cho second:hangul];
                 if (self.keyboardLayout != DKSTHangulKeyboardLayoutDubeolsik &&
                     compoundCho) {
                     _cho = compoundCho;
                     return YES;
                 }
                 // Flush prev Cho, start new
                 [_completed appendFormat:@"%C", [self compatibilityJamo:_cho]];
                 _cho = hangul;
            }
        } else {
            // Already have Jung.
            if (_jong == 0) {
                // Moa-jjiki Case: Jung only (no Cho)?
                if (_cho == 0) {
                    if (self.moaJjikiEnabled) {
                        _cho = hangul; // ㅏ + ㄱ -> 가
                        return YES;
                    } else {
                        // Moa-jjiki Disabled: Flush Jung, start new Cho
                         [_completed appendFormat:@"%C", [self currentSyllable]];
                         _cho = hangul; _jung = 0; _jong = 0;
                         return YES;
                    }
                }
                
                // Normal Case: Cho+Jung + Cho -> Check Jongseong
                if (self.keyboardLayout != DKSTHangulKeyboardLayoutDubeolsik) {
                    [_completed appendFormat:@"%C", [self currentSyllable]];
                    _cho = hangul; _jung = 0; _jong = 0;
                    return YES;
                }
                unichar asJong = [self choToJong:hangul];
                if (asJong) {
                    _jong = asJong;
                } else {
                    // Start new syllable
                    [_completed appendFormat:@"%C", [self currentSyllable]];
                    _cho = hangul; _jung = 0; _jong = 0;
                }
            } else { // Cho+Jung+Jong
                if (self.keyboardLayout != DKSTHangulKeyboardLayoutDubeolsik) {
                    [_completed appendFormat:@"%C", [self currentSyllable]];
                    _cho = hangul; _jung = 0; _jong = 0;
                    return YES;
                }

                // Compound Jongseong?
                unichar compound = [self combineJong:_jong second:[self choToJong:hangul]];
                if (compound) {
                    _jong = compound;
                } else {
                    // Flush, start new
                    [_completed appendFormat:@"%C", [self currentSyllable]];
                    _cho = hangul; _jung = 0; _jong = 0;
                }
            }
        }
    } else if ([self isJong:hangul]) {
        if (_cho && _jung) {
            if (_jong == 0) {
                _jong = hangul;
            } else {
                unichar compound = [self combineJong:_jong second:hangul];
                if (compound) {
                    _jong = compound;
                } else {
                    [_completed appendFormat:@"%C", [self currentSyllable]];
                    _cho = 0; _jung = 0; _jong = hangul;
                }
            }
        } else {
            if (_cho || _jung || _jong) {
                [_completed appendFormat:@"%C", [self currentSyllable]];
            }
            _cho = 0; _jung = 0; _jong = hangul;
        }
    } else if ([self isJung:hangul]) {
        if (_jong) {
            if (self.keyboardLayout != DKSTHangulKeyboardLayoutDubeolsik) {
                [_completed appendFormat:@"%C", [self currentSyllable]];
                _cho = 0; _jung = hangul; _jong = 0;
                return YES;
            }

            // Cho+Jung+Jong + Jung -> Move Jong to next Cho
            unichar j1 = 0, j2 = 0;
            [self splitJong:_jong first:&j1 second:&j2];
            
            if (j2) {
                _jong = j1;
                unichar nextCho = [self jongToCho:j2];
                [_completed appendFormat:@"%C", [self currentSyllable]];
                _cho = nextCho; _jung = hangul; _jong = 0;
            } else {
                unichar nextCho = [self jongToCho:_jong];
                _jong = 0;
                [_completed appendFormat:@"%C", [self currentSyllable]];
                _cho = nextCho; _jung = hangul; _jong = 0;
            }
        } else if (_jung) {
            // Compound Jung?
            unichar compound = [self combineJung:_jung second:hangul];
            if (compound) {
                _jung = compound;
            } else {
                 [_completed appendFormat:@"%C", [self currentSyllable]];
                 _cho = 0; _jung = hangul; _jong = 0;
            }
        } else {
            // Cho + Jung
             if (_cho) _jung = hangul; 
             else _jung = hangul; // Independent Jung
        }
    }
    
    return YES;
}

- (unichar)asciiFromKeyCode:(NSInteger)code modifiers:(NSUInteger)flags
{
    BOOL shift = (flags & NSEventModifierFlagShift) != 0;
    // Map Mac keycodes to characters
    if (code == 0) return shift ? 'A' : 'a';
    if (code == 1) return shift ? 'S' : 's';
    if (code == 2) return shift ? 'D' : 'd';
    if (code == 3) return shift ? 'F' : 'f';
    if (code == 5) return shift ? 'G' : 'g';
    if (code == 4) return shift ? 'H' : 'h';
    if (code == 38) return shift ? 'J' : 'j';
    if (code == 40) return shift ? 'K' : 'k';
    if (code == 37) return shift ? 'L' : 'l';
    
    if (code == 12) return shift ? 'Q' : 'q';
    if (code == 13) return shift ? 'W' : 'w';
    if (code == 14) return shift ? 'E' : 'e';
    if (code == 15) return shift ? 'R' : 'r';
    if (code == 17) return shift ? 'T' : 't';
    if (code == 16) return shift ? 'Y' : 'y';
    if (code == 32) return shift ? 'U' : 'u';
    if (code == 34) return shift ? 'I' : 'i';
    if (code == 31) return shift ? 'O' : 'o';
    if (code == 35) return shift ? 'P' : 'p';
    
    if (code == 6) return shift ? 'Z' : 'z';
    if (code == 7) return shift ? 'X' : 'x';
    if (code == 8) return shift ? 'C' : 'c';
    if (code == 9) return shift ? 'V' : 'v';
    if (code == 11) return shift ? 'B' : 'b';
    if (code == 45) return shift ? 'N' : 'n';
    if (code == 46) return shift ? 'M' : 'm';
    
    if (code == 50) return shift ? '~' : '`';
    if (code == 18) return shift ? '!' : '1';
    if (code == 19) return shift ? '@' : '2';
    if (code == 20) return shift ? '#' : '3';
    if (code == 21) return shift ? '$' : '4';
    if (code == 23) return shift ? '%' : '5';
    if (code == 22) return shift ? '^' : '6';
    if (code == 26) return shift ? '&' : '7';
    if (code == 28) return shift ? '*' : '8';
    if (code == 25) return shift ? '(' : '9';
    if (code == 29) return shift ? ')' : '0';
    if (code == 27) return shift ? '_' : '-';
    if (code == 24) return shift ? '+' : '=';
    if (code == 33) return shift ? '{' : '[';
    if (code == 30) return shift ? '}' : ']';
    if (code == 42) return shift ? '|' : '\\';
    if (code == 41) return shift ? ':' : ';';
    if (code == 39) return shift ? '"' : '\'';
    if (code == 44) return shift ? '?' : '/';
    if (code == 43) return shift ? '<' : ',';
    if (code == 47) return shift ? '>' : '.';
    
    return 0;
}

- (unichar)combineCho:(unichar)a second:(unichar)b {
    if (a == 0x1100 && b == 0x1100) return 0x1101; // ㄱ + ㄱ = ㄲ
    if (a == 0x1103 && b == 0x1103) return 0x1104; // ㄷ + ㄷ = ㄸ
    if (a == 0x1107 && b == 0x1107) return 0x1108; // ㅂ + ㅂ = ㅃ
    if (a == 0x1109 && b == 0x1109) return 0x110A; // ㅅ + ㅅ = ㅆ
    if (a == 0x110C && b == 0x110C) return 0x110D; // ㅈ + ㅈ = ㅉ
    return 0;
}

- (unichar)choToJong:(unichar)c {
    switch(c) {
        case 0x1100: return 0x11A8; // ㄱ
        case 0x1101: return 0x11A9; // ㄲ
        case 0x1102: return 0x11AB; // ㄴ
        case 0x1103: return 0x11AE; // ㄷ
        case 0x1105: return 0x11AF; // ㄹ
        case 0x1106: return 0x11B7; // ㅁ
        case 0x1107: return 0x11B8; // ㅂ
        case 0x1109: return 0x11BA; // ㅅ
        case 0x110A: return 0x11BB; // ㅆ
        case 0x110B: return 0x11BC; // ㅇ
        case 0x110C: return 0x11BD; // ㅈ
        case 0x110E: return 0x11BE; // ㅊ
        case 0x110F: return 0x11BF; // ㅋ
        case 0x1110: return 0x11C0; // ㅌ
        case 0x1111: return 0x11C1; // ㅍ
        case 0x1112: return 0x11C2; // ㅎ
    }
    return 0;
}

- (unichar)jongToCho:(unichar)c {
    switch(c) {
        case 0x11A8: return 0x1100;
        case 0x11A9: return 0x1101;
        case 0x11AB: return 0x1102;
        case 0x11AE: return 0x1103;
        case 0x11AF: return 0x1105;
        case 0x11B7: return 0x1106;
        case 0x11B8: return 0x1107;
        case 0x11BA: return 0x1109;
        case 0x11BB: return 0x110A;
        case 0x11BC: return 0x110B;
        case 0x11BD: return 0x110C;
        case 0x11BE: return 0x110E;
        case 0x11BF: return 0x110F;
        case 0x11C0: return 0x1110;
        case 0x11C1: return 0x1111;
        case 0x11C2: return 0x1112;
    }
    return 0;
}

- (unichar)combineJung:(unichar)a second:(unichar)b {
    if (a == 0x1169 && b == 0x1161) return 0x116A; // ㅘ
    if (a == 0x1169 && b == 0x1162) return 0x116B; // ㅙ
    if (a == 0x1169 && b == 0x1175) return 0x116C; // ㅚ
    if (a == 0x116e && b == 0x1165) return 0x116F; // ㅝ
    if (a == 0x116e && b == 0x1166) return 0x1170; // ㅞ
    if (a == 0x116e && b == 0x1175) return 0x1171; // ㅟ
    if (a == 0x1173 && b == 0x1175) return 0x1174; // ㅢ
    return 0;
}

- (void)splitJung:(unichar)c first:(unichar*)j1 second:(unichar*)j2 {
    *j1 = c; *j2 = 0;
    switch(c) {
        case 0x116A: *j1 = 0x1169; *j2 = 0x1161; break; // ㅘ
        case 0x116B: *j1 = 0x1169; *j2 = 0x1162; break; // ㅙ
        case 0x116C: *j1 = 0x1169; *j2 = 0x1175; break; // ㅚ
        case 0x116F: *j1 = 0x116e; *j2 = 0x1165; break; // ㅝ
        case 0x1170: *j1 = 0x116e; *j2 = 0x1166; break; // ㅞ
        case 0x1171: *j1 = 0x116e; *j2 = 0x1175; break; // ㅟ
        case 0x1174: *j1 = 0x1173; *j2 = 0x1175; break; // ㅢ
    }
}

- (unichar)combineJong:(unichar)a second:(unichar)b {
    // Correct and Full Table for Double Jongseong
    // a is already Jongseong, b is Jongseong
    
    // ㄱ(A8) + ㅅ(BA) = ㄳ(AA)
    if (a == 0x11A8 && b == 0x11BA) return 0x11AA;
    
    // ㄴ(AB) + ㅈ(BD) = ㄵ(AC)
    if (a == 0x11AB && b == 0x11BD) return 0x11AC;
    // ㄴ(AB) + ㅎ(C2) = ㄶ(AD)
    if (a == 0x11AB && b == 0x11C2) return 0x11AD;
    
    // ㄹ(AF) + ㄱ(A8) = ㄺ(B0)
    if (a == 0x11AF && b == 0x11A8) return 0x11B0;
    // ㄹ(AF) + ㅁ(B7) = ㄻ(B1)
    if (a == 0x11AF && b == 0x11B7) return 0x11B1;
    // ㄹ(AF) + ㅂ(B8) = ㄼ(B2)
    if (a == 0x11AF && b == 0x11B8) return 0x11B2;
    // ㄹ(AF) + ㅅ(BA) = ㄽ(B3)
    if (a == 0x11AF && b == 0x11BA) return 0x11B3;
    // ㄹ(AF) + ㅌ(C0) = ㄾ(B4)
    if (a == 0x11AF && b == 0x11C0) return 0x11B4;
    // ㄹ(AF) + ㅍ(C1) = ㄿ(B5)
    if (a == 0x11AF && b == 0x11C1) return 0x11B5;
    // ㄹ(AF) + ㅎ(C2) = ㅀ(B6) -> "닳" requires this!
    if (a == 0x11AF && b == 0x11C2) return 0x11B6;
    
    // ㅂ(B8) + ㅅ(BA) = ㅄ(B9)
    if (a == 0x11B8 && b == 0x11BA) return 0x11B9;
    
    return 0;
}

- (void)splitJong:(unichar)c first:(unichar*)j1 second:(unichar*)j2 {
    *j1 = c; *j2 = 0;
    switch(c) {
        case 0x11AA: *j1 = 0x11A8; *j2 = 0x11BA; break; // ㄳ
        case 0x11AC: *j1 = 0x11AB; *j2 = 0x11BD; break; // ㄵ
        case 0x11AD: *j1 = 0x11AB; *j2 = 0x11C2; break; // ㄶ
        case 0x11B0: *j1 = 0x11AF; *j2 = 0x11A8; break; // ㄺ
        case 0x11B1: *j1 = 0x11AF; *j2 = 0x11B7; break; // ㄻ
        case 0x11B2: *j1 = 0x11AF; *j2 = 0x11B8; break; // ㄼ
        case 0x11B3: *j1 = 0x11AF; *j2 = 0x11BA; break; // ㄽ
        case 0x11B4: *j1 = 0x11AF; *j2 = 0x11C0; break; // ㄾ
        case 0x11B5: *j1 = 0x11AF; *j2 = 0x11C1; break; // ㄿ
        case 0x11B6: *j1 = 0x11AF; *j2 = 0x11C2; break; // ㅀ (Fix for backspace of 닳)
        case 0x11B9: *j1 = 0x11B8; *j2 = 0x11BA; break; // ㅄ
    }
}

@end
