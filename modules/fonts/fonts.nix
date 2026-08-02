let
  anrtFonts = [
    {
      name = "baskervville";
      sha256 = "sha256-ppQYjkyZRJctxk1pYHaj71NkaVWyiQTk8WZHxAQyvm8=";
      url = "${anrtFontsBaseUrl}/baskervville/46f1017574-1678381500/baskervville-regular.zip";
    }

    {
      name = "baskervville-italic";
      sha256 = "sha256-2MYnAtvVrlLLFDZQ6H5GIJTkZsg+yQOqurNW+kRE/mU=";
      url = "${anrtFontsBaseUrl}/baskervville/271ffa28c0-1678381500/baskervville-italic.zip";
    }

    {
      name = "durandus";
      sha256 = "sha256-Oquj8QP+VPfViPlQFZasySCwKtfiyztNo6w4lq3tUZk=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/0d198ed659-1678381500/gotico-antiqua_durandus-118g.zip";
    }

    {
      name = "hamlet-cicero";
      sha256 = "sha256-D0/l1bAFz8hoTeYDXHQdGfBdGaGJw3PjV158NstaXJM=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/2135df3c7c-1678381560/gotico-antiqua_hamlet-cicero-12.zip";
    }

    {
      name = "hamlet-tertia";
      sha256 = "sha256-2tlWtgS/DFNXX4//vuDLknwE+ayJJTTLyguezzSknDU=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/027c895867-1678381500/gotico-antiqua_hamlet-tertia-18.zip";
    }

    {
      name = "jessen-cicero";
      sha256 = "sha256-EMOe+GsrRuHb/AupQP3VWcrXCmfspWNx80ND1zmM9I4=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/1d094e4f1c-1678381560/gotico-antiqua_jessen-cicero-12.zip";
    }

    {
      name = "jessen-mittel";
      sha256 = "sha256-YfJzxZOxAOpQ2Nw04w9WTWdubdyoTxwUL0p5MpLUlsQ=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/0944f51447-1678381560/gotico-antiqua_jessen-mittel-14.zip";
    }

    {
      name = "parix-hybrid";
      sha256 = "sha256-xacMfjQCQoUJIsrfUzKeVt55bWjYz6OZ6w2vAl3o7/A=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/23369f227f-1678381500/gotico-antiqua_parix-111r.zip";
    }

    {
      name = "ptolemy-great-primer";
      sha256 = "sha256-8zr8zCti15eYaP8SljaDIWPQC24BBfEK3OmeZw2c91M=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/b6041b6798-1678381500/gotico-antiqua_ptolemy.zip";
    }

    {
      name = "rot-proto-roman";
      sha256 = "sha256-M2nF7Gu3APiKGTDl48IQkq2Wx/l18BXFgu3YEHfM2d4=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/95c21c313b-1678381500/gotico-antiqua_rot-102r.zip";
    }

    {
      name = "rusch-gotico-antiqua";
      sha256 = "sha256-e9EgCkjM3DsSXpgtJjL99Q/L3kGhJ4QouWj5io0GdD4=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/0b9237368a-1678381500/gotico-antiqua_rusch-100g.zip";
    }

    {
      name = "rusch-bizarre";
      sha256 = "sha256-xxSOM9crhXNQgUHC/zCUiMU3D1+2aiDDS1/s+t7VB3c=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/8d5addb4f8-1678381500/gotico-antiqua_r-bizarre-103r.zip";
    }

    {
      name = "soufflet-vert-hybrid";
      sha256 = "sha256-S/BLyEoycStpEByF5syUPAy9IeZsQKAiMv6rQR/lBEY=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/becd45c481-1678381500/gotico-antiqua_soufflet-vert-106r.zip";
    }

    {
      name = "spira-proto-roman";
      sha256 = "sha256-Porb7AEy2WB9AuCNoeI2skygXuggh8H2xFRbm6jwqho=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/10a7f06f11-1678381500/gotico-antiqua_spira-110r.zip";
    }

    {
      name = "proto-roman";
      sha256 = "sha256-cNKWtClTeONR45IXjE7R0JxpMCOA5B2uDGX8t3h/8MA=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/1eb0e9fc41-1678381560/gotico-antiqua_sweynheim-pannartz-115r.zip";
    }

    {
      name = "subiaco";
      sha256 = "sha256-0u3jvB7+WqFwBfMrCOPSMNAN5QOxVO9CXUNNZKZm2eM=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/c3eb075c42-1678381560/gotico-antiqua_sweynheim-pannartz-120r.zip";
    }

    {
      name = "zainer-gotico-antiqua";
      sha256 = "sha256-MPS5RiftUTRSmWxrCWuCRZX0maCBjy/Y/LSSX4xvlV8=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/41176b1583-1678381560/gotico-antiqua_zainer-96g.zip";
    }

    {
      name = "zainer-initials";
      sha256 = "sha256-RQzAx0aYapFILaj4p/yVHKqZk7uQ8XZp9RfOBiDGS5M=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/ada76d5805-1678381560/gotico-antiqua_zainer-initials.zip";
    }
  ];

  anrtFontsBaseUrl = "https://anrt-nancy.fr/media/pages/fonts";

  hersheyFonts = let
    baseAttrs = {
      dontUnpack = true;
      ttf = true;
    };
  in [
    (
      baseAttrs
      // {
        name = "AVHersheyComplexHeavyItalic";
        sha256 = "sha256-VBJfqjC0QCKEKYsHSfhC23pDOgx7ESKiAve3hbIaCkY=";
        url = "${hersheyFontsBaseUrl}/AVHersheyComplexHeavyItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyComplexHeavy";
        sha256 = "sha256-AaMvjVZePkM04B8Gk9Ajo7yqBhhkugv/mKY0/+0DmoE=";
        url = "${hersheyFontsBaseUrl}/AVHersheyComplexHeavy.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyComplexLightItalic";
        sha256 = "sha256-T+1jb2qyx6MJXPge5Pe731jYLCaqWJg4qpK9ztinSNU=";
        url = "${hersheyFontsBaseUrl}/AVHersheyComplexLightItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyComplexLight";
        sha256 = "sha256-v/IWxLLaWQA1yl5TeysKWQRAUa1RH02zDX5Hc8CPqLM=";
        url = "${hersheyFontsBaseUrl}/AVHersheyComplexLight.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyComplexMediumItalic";
        sha256 = "sha256-5pFjXwWK4ZdltD71FWQDrusde1moDbYIUHGG9p8u1pw=";
        url = "${hersheyFontsBaseUrl}/AVHersheyComplexMediumItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyComplexMedium";
        sha256 = "sha256-gSlgv6k8n0rr2QooBqXlErfF2CiCHSuYpRZjRphPEzk=";
        url = "${hersheyFontsBaseUrl}/AVHersheyComplexMedium.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyDuplexHeavyItalic";
        sha256 = "sha256-YMtG3wV+CKTMLpIzD6vZIM/fo9RLLEqNGRKWb6eztFY=";
        url = "${hersheyFontsBaseUrl}/AVHersheyDuplexHeavyItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyDuplexHeavy";
        sha256 = "sha256-8Fwi4DxoKlE9kpn4h1ufqMj089o4FYFRJOd7IiwTjTk=";
        url = "${hersheyFontsBaseUrl}/AVHersheyDuplexHeavy.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyDuplexLightItalic";
        sha256 = "sha256-eMF829l6PZuXJLBViPTBe0aTP26EK1vAmqW5NWfdFZU=";
        url = "${hersheyFontsBaseUrl}/AVHersheyDuplexLightItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyDuplexLight";
        sha256 = "sha256-S9tijbkOeMU4LFoDiCB20sUu11p565Jz7n3TPi0kARs=";
        url = "${hersheyFontsBaseUrl}/AVHersheyDuplexLight.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyDuplexMediumItalic";
        sha256 = "sha256-bmBxRsRR1x04bTitk/XtC3WQAYyysXHqSY/gp+RT9v4=";
        url = "${hersheyFontsBaseUrl}/AVHersheyDuplexMediumItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheyDuplexMedium";
        sha256 = "sha256-2pZkdZAuOawpp1ywpcsKAE1oQH1u3UKrIcTNhWLnaLI=";
        url = "${hersheyFontsBaseUrl}/AVHersheyDuplexMedium.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheySimplexHeavyItalic";
        sha256 = "sha256-YfPqAbWGNTrQiU/+jrwbucMCTUzVtMsLzCsVywajkMA=";
        url = "${hersheyFontsBaseUrl}/AVHersheySimplexHeavyItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheySimplexHeavy";
        sha256 = "sha256-hQ8JDo0djMfluj7LJ2XZ+g+Blf5bLkuI5b2D+gXneTA=";
        url = "${hersheyFontsBaseUrl}/AVHersheySimplexHeavy.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheySimplexLightItalic";
        sha256 = "sha256-0n27pPbhRoY33M1pum8nrP4Zr9rgOYB3WuOPpFaWO8I=";
        url = "${hersheyFontsBaseUrl}/AVHersheySimplexLightItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheySimplexLight";
        sha256 = "sha256-42N3Wbo5JNte9HXe2SaZouYlHK+o627HV8eu9fLI1YA=";
        url = "${hersheyFontsBaseUrl}/AVHersheySimplexLight.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheySimplexMediumItalic";
        sha256 = "sha256-ByJHYJOd7UHLm7ylSipwj+TLeWGuSzXdOKZCnJP4TU8=";
        url = "${hersheyFontsBaseUrl}/AVHersheySimplexMediumItalic.ttf";
      }
    )

    (
      baseAttrs
      // {
        name = "AVHersheySimplexMedium";
        sha256 = "sha256-lq+W2gi3kcuRQGrBit+AR+uUk98MDJuayqrERQjry88=";
        url = "${hersheyFontsBaseUrl}/AVHersheySimplexMedium.ttf";
      }
    )
  ];

  hersheyFontsBaseUrl = "https://github.com/yangcht/Hershey_font_TTF/raw/refs/heads/main/ttf";
in
  [
    {
      dontUnpack = true;
      name = "kelmscott-mono";
      sha256 = "sha256-fv0bT1hHAAvF0PyIBG0pVf+N1SEhHw7pkTpy0+yAwno=";
      url = "https://github.com/seeddisperser/kelmscott-mono/raw/refs/heads/main/KelmscottMono.otf";
    }

    {
      name = "no-tears";
      sha256 = "sha256-M9WHCW5i5HlW1Bkg4Dd7raK4i8KHvO5wKJnezYnN4YQ=";
      ttf = true;
      url = "https://indestructibletype.com/notears.zip";
    }

    {
      name = "apl385";
      sha256 = "sha256-xT5KK7FY7zEcfWVz/nqHIRYWaS9fU2+5BCclt+YgIdw=";
      ttf = true;
      url = "https://apl385.com/fonts/apl385.zip";
    }

    {
      dontUnpack = true;
      name = "apl386";
      sha256 = "sha256-zNVQu8Dh9J9KXtoOItYLAF3gFeBf8Y6kdEgOUInGj9g=";
      ttf = true;
      url = "https://abrudz.github.io/APL386/APL386.ttf";
    }

    {
      dontUnpack = true;
      name = "apl387";
      sha256 = "sha256-KyMJIkBdx7bndXqOhbpVOGkGEcPrn8peLw5q1/hKVzM=";
      ttf = true;
      url = "https://dyalog.github.io/APL387/APL387.ttf";
    }
  ]
  ++ anrtFonts ++ hersheyFonts
